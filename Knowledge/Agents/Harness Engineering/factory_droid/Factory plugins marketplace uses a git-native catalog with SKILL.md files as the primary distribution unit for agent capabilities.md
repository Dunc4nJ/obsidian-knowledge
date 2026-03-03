---
created: 2026-03-02
description: The factory-plugins repository reveals how Factory distributes agent capabilities as a curated marketplace of skill bundles, each packaged with YAML-frontmatter SKILL.md files, plugin.json metadata, and a flat marketplace.json catalog — with skills ranging from security review to browser automation to writing style enforcement.
source: https://github.com/Factory-AI/factory-plugins
---

## Key Takeaways

The factory-plugins repository is the canonical example of how [[Factory Droid plugins bundle skills commands hooks and MCP servers into distributable packages with marketplace-based discovery|Factory's plugin system]] works in practice. The marketplace is a single Git repository containing three plugins (core, droid-evolved, security-engineer), each with a `.factory-plugin/plugin.json` manifest and a `skills/` directory containing one `SKILL.md` per capability. The marketplace catalog at `.factory-plugin/marketplace.json` is a flat JSON array — no dependency resolution, no version pinning, just name-description-source-category tuples pointing to local paths.

The plugin directory structure confirms what the [[Factory Droid plugins bundle skills commands hooks and MCP servers into distributable packages with marketplace-based discovery|plugin documentation]] describes: `plugin.json` contains only `name`, `description`, and `author` — minimal metadata with no version field, dependency declarations, or compatibility constraints. This is consistent with Factory's commit-hash-based versioning strategy where plugins always pull latest.

SKILL.md files use YAML frontmatter with `name`, `version`, and `description` fields. The `description` field doubles as a trigger specification — it tells the model when to activate the skill. For example, the browser-navigation skill's description lists specific user intents ("Navigate websites", "Fill forms", "Take screenshots") that act as semantic routing rules. This pattern resembles [[Factory positions Droid as an agent-native platform spanning CLI web Slack Linear and mobile with a community-driven plugin ecosystem|Droid's platform-level skill invocation model]].

The security-engineer plugin demonstrates a multi-skill pipeline architecture: threat-model-generation produces `.factory/threat-model.md`, commit-security-scan reads that model to generate `security-findings.json`, vulnerability-validation confirms findings into `validated-findings.json`, and security-review orchestrates the full flow. Each skill is independently invocable but designed to chain through filesystem artifacts — a file-based inter-skill communication pattern.

The human-writing skill is notable as a meta-skill that encodes Wikipedia's "Signs of AI writing" patterns into a reusable capability. It includes before/after examples for every pattern category (inflated significance, promotional language, AI vocabulary words, em dash overuse, rule of three). This kind of style-enforcement skill represents a novel use of the plugin system beyond tooling — using skills to shape the agent's writing voice.

The skill-creation skill is self-referential: it's a skill that teaches the agent how to create new skills, referencing academic work on agent learning (Voyager, CASCADE, SEAgent, Reflexion). This confirms [[Factory positions Droid as an agent-native platform spanning CLI web Slack Linear and mobile with a community-driven plugin ecosystem|Factory's vision]] of a continuously self-improving agent that extracts reusable capabilities from its own sessions.

The visual-design skill delegates to external CLIs (`nanobanana` for image generation, `slidev` for presentations) and the browser-navigation skill wraps `agent-browser` — showing that skills are thin instructional wrappers around existing tools rather than self-contained implementations.

## External Resources

- [Factory-AI/factory-plugins](https://github.com/Factory-AI/factory-plugins) — the official marketplace repository
- [agent-browser npm package](https://www.npmjs.com/package/agent-browser) — browser automation CLI used by the browser-navigation skill
- [Slidev](https://sli.dev/) — markdown-based presentation tool used by visual-design skill
- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) — source for the human-writing skill patterns
- [STRIDE Threat Modeling](https://docs.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats) — framework used by security-engineer skills
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) — reference for security scanning patterns

## Original Content

> [!quote]- Full Repository Content
>
> ### Repository Structure
>
> ```
> factory-plugins/
> ├── .factory-plugin/
> │   └── marketplace.json
> ├── README.md
> └── plugins/
>     ├── core/
>     │   ├── .factory-plugin/
>     │   │   └── plugin.json
>     │   └── skills/
>     │       ├── init/
>     │       │   └── SKILL.md
>     │       └── session-navigation/
>     │           └── SKILL.md
>     ├── droid-evolved/
>     │   ├── .factory-plugin/
>     │   │   └── plugin.json
>     │   └── skills/
>     │       ├── browser-navigation/
>     │       │   └── SKILL.md
>     │       ├── frontend-design/
>     │       │   └── SKILL.md
>     │       ├── human-writing/
>     │       │   └── SKILL.md
>     │       ├── skill-creation/
>     │       │   └── SKILL.md
>     │       └── visual-design/
>     │           ├── SKILL.md
>     │           ├── image-generation.md
>     │           ├── presentations.md
>     │           └── reference-slide-example.md
>     └── security-engineer/
>         ├── .factory-plugin/
>         │   └── plugin.json
>         └── skills/
>             ├── commit-security-scan/
>             │   ├── SKILL.md
>             │   └── analysis-examples.md
>             ├── security-review/
>             │   └── SKILL.md
>             ├── threat-model-generation/
>             │   ├── SKILL.md
>             │   └── stride-template.md
>             └── vulnerability-validation/
>                 ├── SKILL.md
>                 └── validation-examples.md
> ```
>
> ---
>
> ### README.md
>
> # Factory Plugins Marketplace
>
> Official Factory plugins marketplace containing curated skills, droids, and tools.
>
> ## Installation
>
> Add this marketplace to Factory:
>
> ```bash
> droid plugin marketplace add https://github.com/Factory-AI/factory-plugins
> ```
>
> Then install plugins:
>
> ```bash
> droid plugin install security-engineer@factory-plugins
> ```
>
> Or browse available plugins via the UI:
>
> ```
> /plugins
> ```
>
> ## Available Plugins
>
> ### security-engineer
>
> Security review, threat modeling, and vulnerability validation skills.
>
> **Skills:**
>
> - `security-review` - STRIDE-based security analysis
> - `threat-model-generation` - Generate threat models for repositories
> - `commit-security-scan` - Scan commits/PRs for security vulnerabilities
> - `vulnerability-validation` - Validate and confirm security findings
>
> ### droid-evolved
>
> Skills for continuous learning and improvement.
>
> **Skills:**
>
> - `session-navigation` - Search and navigate past Droid sessions
> - `human-writing` - Remove AI writing patterns, make text sound human
> - `skill-creation` - Create and improve Droid skills
> - `visual-design` - Image generation (nanobanana CLI) and presentations (Slidev)
> - `frontend-design` - Build web apps, websites, HTML pages with good design
> - `browser-navigation` - Browser automation with agent-browser
>
> ## Plugin Structure
>
> Each plugin follows the Factory plugin format:
>
> ```
> plugin-name/
> ├── .factory-plugin/
> │   └── plugin.json       # Plugin metadata
> ├── skills/               # Skill definitions
> │   └── skill-name/
> │       └── SKILL.md
> ├── droids/               # Droid definitions (optional)
> ├── commands/             # Custom commands (optional)
> ├── mcp.json              # MCP server config (optional)
> └── hooks.json            # Hook configurations (optional)
> ```
>
> ## Contributing
>
> 1. Fork this repository
> 2. Add your plugin under `plugins/`
> 3. Update the marketplace.json
> 4. Submit a pull request
>
> ---
>
> ### .factory-plugin/marketplace.json
>
> ```json
> {
>   "name": "factory-plugins",
>   "description": "Official Factory plugins marketplace",
>   "owner": {
>     "name": "Factory",
>     "email": "support@factory.ai"
>   },
>   "plugins": [
>     {
>       "name": "security-engineer",
>       "description": "Security review, threat modeling, and vulnerability validation skills",
>       "source": "./plugins/security-engineer",
>       "category": "security"
>     },
>     {
>       "name": "droid-evolved",
>       "description": "Skills for continuous learning and improvement: session navigation, human writing, skill creation, visual design, and browser automation",
>       "source": "./plugins/droid-evolved",
>       "category": "productivity"
>     },
>     {
>       "name": "core",
>       "description": "Core Skills for essential functionalities and integrations",
>       "source": "./plugins/core",
>       "category": "core"
>     }
>   ]
> }
> ```
>
> ---
>
> ### plugins/core/.factory-plugin/plugin.json
>
> ```json
> {
>   "name": "core",
>   "description": "Core Skills for essential functionalities and integrations",
>   "author": {
>     "name": "Factory",
>     "email": "support@factory.ai"
>   }
> }
> ```
>
> ---
>
> ### plugins/droid-evolved/.factory-plugin/plugin.json
>
> ```json
> {
>   "name": "droid-evolved",
>   "description": "Skills for continuous learning and improvement: session navigation, human writing, skill creation, visual design, and browser automation",
>   "author": {
>     "name": "Factory",
>     "email": "support@factory.ai"
>   }
> }
> ```
>
> ---
>
> ### plugins/security-engineer/.factory-plugin/plugin.json
>
> ```json
> {
>   "name": "security-engineer",
>   "description": "Security review, threat modeling, and vulnerability validation skills",
>   "author": {
>     "name": "Factory",
>     "email": "support@factory.ai"
>   }
> }
> ```
>
> ---
>
> ### plugins/core/skills/init/SKILL.md
>
> ```yaml
> ---
> name: init
> version: 1.0.0
> description: Initialize a new repository with AGENTS.md
> disable-model-invocation: true
> ---
> ```
>
> Please analyze this codebase and create a AGENTS.md file, which will be given to future instances of Droid to operate in this repository.
>
> What to add:
>
> 1. Commands that will be commonly used, such as how to build, lint, and run tests. Include the necessary commands to develop in this codebase, such as how to run a single test.
> 2. High-level code architecture and structure so that future instances can be productive more quickly. Focus on the "big picture" architecture that requires reading multiple files to understand.
>
> Usage notes:
>
> - After analyzing the codebase, if no AGENTS.md exists, create it directly. If an AGENTS.md already exists, show the proposed new contents and ask for confirmation before modifying the file.
> - When you make the initial AGENTS.md, do not repeat yourself and do not include obvious instructions like "Provide helpful error messages to users", "Write unit tests for all new utilities", "Never include sensitive information (API keys, tokens) in code or commits".
> - Avoid listing every component or file structure that can be easily discovered.
> - Don't include generic development practices.
> - If there are Cursor rules (in .cursor/rules/ or .cursorrules), Copilot rules (in .github/copilot-instructions.md), or CLAUDE.md files, make sure to include the important parts.
> - If there is a README.md, make sure to include the important parts.
> - Do not make up information such as "Common Development Tasks", "Tips for Development", "Support and Documentation" unless this is expressly included in other files that you read.
>
> ---
>
> ### plugins/core/skills/session-navigation/SKILL.md
>
> ```yaml
> ---
> name: session-navigation
> version: 1.1.0
> description: |
>   Navigate, search, and manage Droid sessions. Use when the user wants to:
>   - List recent sessions
>   - Search session history for specific topics or patterns
>   - Resume a previous session
>   - Get details about what was accomplished in a session
>   - Find sessions by project, date, or content
> ---
> ```
>
> # Session navigation
>
> Find your way around past Droid sessions. Maybe you want to pick up where you left off, find that thing you did last week, or just see what's been happening in a project.
>
> ## Where sessions live
>
> Sessions are in `~/.factory/sessions/`, organized by project folder. Each project gets its own directory with the path encoded (slashes become dashes):
>
> ```
> ~/.factory/sessions/
> ├── -Users-enoreyes-code-work-myapp/
> │   ├── <uuid>.jsonl
> │   └── <uuid>.settings.json
> ├── -Users-enoreyes-code-projects-api/
> │   ├── <uuid>.jsonl
> │   └── <uuid>.settings.json
> └── ...
> ```
>
> Two files per session:
>
> **The conversation** (`.jsonl`): Each line is a JSON object. First line has metadata (session id, title, working directory). Rest is the back-and-forth: user messages, assistant responses, tool calls.
>
> **The settings** (`.settings.json`): Stats about the session. Which model, how long it ran, token counts, autonomy mode.
>
> ## Finding sessions
>
> ### List project folders
>
> ```bash
> # See all project folders with sessions
> ls ~/.factory/sessions/
>
> # Find folders for a specific project (partial match)
> ls ~/.factory/sessions/ | grep "myapp"
> ```
>
> ### Recent sessions in a project
>
> ```bash
> # List sessions by date for a project
> ls -lt ~/.factory/sessions/-Users-enoreyes-code-work-myapp/
>
> # Get titles of recent sessions
> for f in $(ls -t ~/.factory/sessions/-Users-enoreyes-code-work-myapp/*.jsonl | head -10); do
>   echo "=== $f ==="
>   head -1 "$f" | jq -r '.title // "Untitled"'
> done
> ```
>
> ### Search by content
>
> ```bash
> # Search across ALL sessions
> rg "authentication" ~/.factory/sessions/
>
> # Search within a specific project
> rg "bug fix" ~/.factory/sessions/-Users-enoreyes-code-work-myapp/
>
> # See matches in context
> rg -C 2 "login" ~/.factory/sessions/-Users-enoreyes-code-projects-api/
> ```
>
> ### Find which project has sessions about something
>
> ```bash
> # Which projects have sessions mentioning "redis"?
> rg -l "redis" ~/.factory/sessions/ | cut -d'/' -f1-5 | sort -u
> ```
>
> ## Reading a session
>
> Once you've found a session file:
>
> ```bash
> # The metadata (title, working directory)
> head -1 ~/.factory/sessions/-Users-enoreyes-code-work-myapp/<uuid>.jsonl | jq .
>
> # Session stats (model, tokens, duration)
> cat ~/.factory/sessions/-Users-enoreyes-code-work-myapp/<uuid>.settings.json | jq .
>
> # How long was this conversation?
> wc -l ~/.factory/sessions/-Users-enoreyes-code-work-myapp/<uuid>.jsonl
> ```
>
> User messages have `"role": "user"`, assistant responses have `"role": "assistant"`. Tool calls show what commands ran and what files got touched.
>
> ## Common situations
>
> **"What did I work on in this project?"**
> List that project's session folder, check dates, read through the conversation files.
>
> **"Find that session where we fixed the login bug"**
> Search for "login" or "auth" across sessions. Once you find it, read the conversation.
>
> **"Resume what I was doing"**
> Find the session, read through what happened, summarize the key decisions before continuing.
>
> **"How much have I been using Droid?"**
> The settings files have token counts and active time. Sum across sessions if needed.
>
> ## Tips
>
> Use `rg` (ripgrep) instead of grep. It's faster and handles nested folders better.
>
> Project paths have slashes replaced with dashes. `/Users/me/code/app` becomes `-Users-me-code-app`.
>
> The session title isn't always helpful. Sometimes you need to read the conversation to know what it was about.
>
> Sessions can contain sensitive stuff. Be careful about what you surface.
>
> ---
>
> ### plugins/droid-evolved/skills/browser-navigation/SKILL.md
>
> ```yaml
> ---
> name: browser-navigation
> version: 1.0.0
> description: |
>   Automate browser interactions for web testing, form filling, screenshots, and data extraction.
>   Use when the user needs to:
>   - Navigate websites and interact with web pages
>   - Fill forms and click buttons
>   - Take screenshots of web content
>   - Test web applications
>   - Extract information from web pages
>   - Debug frontend issues in the browser
>   - Monitor console logs and network requests
>   - Record browser sessions as video
>   This skill uses agent-browser for comprehensive browser automation.
>   RECOMMENDATION: Disable Chrome DevTools or Playwright MCP when using this skill to save context.
> ---
> ```
>
> # Browser Automation with agent-browser
>
> Comprehensive browser automation for testing, data extraction, and web interaction.
>
> ## Quick Start
>
> ```bash
> agent-browser open <url>        # Navigate to page
> agent-browser snapshot -i       # Get interactive elements with refs
> agent-browser click @e1         # Click element by ref
> agent-browser fill @e2 "text"   # Fill input by ref
> agent-browser close             # Close browser
> ```
>
> ## Core Workflow
>
> 1. **Navigate**: `agent-browser open <url>`
> 2. **Snapshot**: `agent-browser snapshot -i` (returns elements with refs like `@e1`, `@e2`)
> 3. **Interact** using refs from the snapshot
> 4. **Re-snapshot** after navigation or significant DOM changes
>
> ## Installation
>
> ```bash
> # Install globally
> npm install -g agent-browser
>
> # Or use via npx
> npx agent-browser open https://example.com
> ```
>
> ## Commands Reference
>
> ### Navigation
>
> ```bash
> agent-browser open <url>      # Navigate to URL
> agent-browser back            # Go back
> agent-browser forward         # Go forward
> agent-browser reload          # Reload page
> agent-browser close           # Close browser
> ```
>
> ### Page Analysis (Snapshot)
>
> ```bash
> agent-browser snapshot            # Full accessibility tree
> agent-browser snapshot -i         # Interactive elements only (RECOMMENDED)
> agent-browser snapshot -c         # Compact output
> agent-browser snapshot -d 3       # Limit depth to 3
> agent-browser snapshot -s "#main" # Scope to CSS selector
> ```
>
> ### Interactions (Use @refs from Snapshot)
>
> ```bash
> # Clicking
> agent-browser click @e1           # Click
> agent-browser dblclick @e1        # Double-click
> agent-browser hover @e1           # Hover
>
> # Focus
> agent-browser focus @e1           # Focus element
>
> # Text Input
> agent-browser fill @e2 "text"     # Clear and type
> agent-browser type @e2 "text"     # Type without clearing
>
> # Keyboard
> agent-browser press Enter         # Press key
> agent-browser press Control+a     # Key combination
> agent-browser keydown Shift       # Hold key down
> agent-browser keyup Shift         # Release key
>
> # Forms
> agent-browser check @e1           # Check checkbox
> agent-browser uncheck @e1         # Uncheck checkbox
> agent-browser select @e1 "value"  # Select dropdown option
>
> # Scrolling
> agent-browser scroll down 500     # Scroll page
> agent-browser scrollintoview @e1  # Scroll element into view
>
> # Other
> agent-browser drag @e1 @e2        # Drag and drop
> agent-browser upload @e1 file.pdf # Upload files
> ```
>
> ### Getting Information
>
> ```bash
> agent-browser get text @e1        # Get element text
> agent-browser get html @e1        # Get innerHTML
> agent-browser get value @e1       # Get input value
> agent-browser get attr @e1 href   # Get attribute
> agent-browser get title           # Get page title
> agent-browser get url             # Get current URL
> agent-browser get count ".item"   # Count matching elements
> agent-browser get box @e1         # Get bounding box
> ```
>
> ### Checking State
>
> ```bash
> agent-browser is visible @e1      # Check if visible
> agent-browser is enabled @e1      # Check if enabled
> agent-browser is checked @e1      # Check if checked
> ```
>
> ### Screenshots & PDF
>
> ```bash
> agent-browser screenshot          # Screenshot to stdout
> agent-browser screenshot path.png # Save to file
> agent-browser screenshot --full   # Full page
> agent-browser pdf output.pdf      # Save as PDF
> ```
>
> ### Video Recording
>
> ```bash
> agent-browser record start ./demo.webm    # Start recording
> agent-browser click @e1                   # Perform actions
> agent-browser record stop                 # Stop and save video
> agent-browser record restart ./take2.webm # Stop current + start new
> ```
>
> ### Waiting
>
> ```bash
> agent-browser wait @e1                     # Wait for element
> agent-browser wait 2000                    # Wait milliseconds
> agent-browser wait --text "Success"        # Wait for text
> agent-browser wait --url "**/dashboard"    # Wait for URL pattern
> agent-browser wait --load networkidle      # Wait for network idle
> agent-browser wait --fn "window.ready"     # Wait for JS condition
> ```
>
> ### Cookies & Storage
>
> ```bash
> agent-browser cookies                     # Get all cookies
> agent-browser cookies set name value      # Set cookie
> agent-browser cookies clear               # Clear cookies
> agent-browser storage local               # Get all localStorage
> agent-browser storage local key           # Get specific key
> agent-browser storage local set k v       # Set value
> agent-browser storage local clear         # Clear all
> ```
>
> ### Network
>
> ```bash
> agent-browser network route <url>              # Intercept requests
> agent-browser network route <url> --abort      # Block requests
> agent-browser network route <url> --body '{}'  # Mock response
> agent-browser network unroute [url]            # Remove routes
> agent-browser network requests                 # View tracked requests
> agent-browser network requests --filter api    # Filter requests
> ```
>
> ### Browser Settings
>
> ```bash
> agent-browser set viewport 1920 1080      # Set viewport size
> agent-browser set device "iPhone 14"      # Emulate device
> agent-browser set geo 37.7749 -122.4194   # Set geolocation
> agent-browser set offline on              # Toggle offline mode
> agent-browser set headers '{"X-Key":"v"}' # Extra HTTP headers
> agent-browser set credentials user pass   # HTTP basic auth
> agent-browser set media dark              # Emulate color scheme
> ```
>
> ### Tabs & Windows
>
> ```bash
> agent-browser tab                 # List tabs
> agent-browser tab new [url]       # New tab
> agent-browser tab 2               # Switch to tab
> agent-browser tab close           # Close tab
> agent-browser window new          # New window
> ```
>
> ### Frames
>
> ```bash
> agent-browser frame "#iframe"     # Switch to iframe
> agent-browser frame main          # Back to main frame
> ```
>
> ### Dialogs
>
> ```bash
> agent-browser dialog accept [text]  # Accept dialog
> agent-browser dialog dismiss        # Dismiss dialog
> ```
>
> ### JavaScript Execution
>
> ```bash
> agent-browser eval "document.title"   # Run JavaScript
> ```
>
> ## Example Workflows
>
> ### Form Submission
>
> ```bash
> agent-browser open https://example.com/form
> agent-browser snapshot -i
> # Output shows: textbox "Email" [ref=e1], textbox "Password" [ref=e2], button "Submit" [ref=e3]
>
> agent-browser fill @e1 "user@example.com"
> agent-browser fill @e2 "password123"
> agent-browser click @e3
> agent-browser wait --load networkidle
> agent-browser snapshot -i  # Check result
> ```
>
> ### Authentication with Saved State
>
> ```bash
> # Login once
> agent-browser open https://app.example.com/login
> agent-browser snapshot -i
> agent-browser fill @e1 "username"
> agent-browser fill @e2 "password"
> agent-browser click @e3
> agent-browser wait --url "**/dashboard"
> agent-browser state save auth.json
>
> # Later sessions: load saved state
> agent-browser state load auth.json
> agent-browser open https://app.example.com/dashboard
> ```
>
> ### Scraping Data
>
> ```bash
> agent-browser open https://example.com/products
> agent-browser snapshot -i --json > page_structure.json
>
> # Get specific data
> agent-browser get text @e5  # Product title
> agent-browser get attr @e6 href  # Product link
> ```
>
> ### Taking Full Page Screenshot
>
> ```bash
> agent-browser open https://example.com
> agent-browser wait --load networkidle
> agent-browser screenshot --full fullpage.png
> ```
>
> ### Testing Login Flow
>
> ```bash
> # Navigate to login
> agent-browser open https://app.example.com/login
>
> # Take initial snapshot
> agent-browser snapshot -i
>
> # Fill credentials
> agent-browser fill @e1 "test@example.com"
> agent-browser fill @e2 "testpassword"
>
> # Click login
> agent-browser click @e3
>
> # Wait for redirect
> agent-browser wait --url "**/dashboard"
>
> # Verify logged in
> agent-browser get text @e10  # Should show username
> ```
>
> ## Debugging
>
> ```bash
> agent-browser open example.com --headed              # Show browser window
> agent-browser console                                # View console messages
> agent-browser console --clear                        # Clear console
> agent-browser errors                                 # View page errors
> agent-browser errors --clear                         # Clear errors
> agent-browser highlight @e1                          # Highlight element
> agent-browser trace start                            # Start recording trace
> agent-browser trace stop trace.zip                   # Stop and save trace
> agent-browser --cdp 9222 snapshot                    # Connect via CDP
> ```
>
> ## Sessions (Parallel Browsers)
>
> ```bash
> agent-browser --session test1 open site-a.com
> agent-browser --session test2 open site-b.com
> agent-browser session list
> ```
>
> ## JSON Output
>
> Add `--json` for machine-readable output:
>
> ```bash
> agent-browser snapshot -i --json
> agent-browser get text @e1 --json
> ```
>
> ## Semantic Locators (Alternative to Refs)
>
> ```bash
> agent-browser find role button click --name "Submit"
> agent-browser find text "Sign In" click
> agent-browser find label "Email" fill "user@test.com"
> agent-browser find first ".item" click
> agent-browser find nth 2 "a" text
> ```
>
> ## Best Practices
>
> 1. **Always snapshot first**: Get the current page state before interacting
> 2. **Use interactive mode (-i)**: Shows only clickable/fillable elements
> 3. **Wait appropriately**: Use `--load networkidle` after navigation
> 4. **Re-snapshot after changes**: DOM updates invalidate refs
> 5. **Save authentication state**: Avoid repeated logins
> 6. **Use --headed for debugging**: See what the browser sees
> 7. **Check console for errors**: `agent-browser console` reveals issues
>
> ## When to Use This Skill
>
> - Testing web applications end-to-end
> - Automating repetitive web tasks
> - Scraping data from websites
> - Debugging frontend issues
> - Taking screenshots for documentation
> - Recording demo videos
> - Verifying UI functionality
> - Filling out forms programmatically
>
> ## Disable conflicting MCPs
>
> If Chrome DevTools or Playwright MCP is enabled, ask the user if they want to disable it to save context. This skill covers the same functionality.
>
> Ask them to run:
> ```
> /mcp
> ```
>
> If they see chrome-devtools or playwright listed, suggest they remove it:
> ```
> /mcp remove chrome-devtools
> /mcp remove playwright
> ```
>
> Don't run these commands yourself. Let the user decide whether to disable the MCP.
>
> ---
>
> ### plugins/droid-evolved/skills/frontend-design/SKILL.md
>
> ```yaml
> ---
> name: frontend-design
> version: 1.0.0
> description: |
>   Build good-looking web interfaces. Use when:
>   - User asks you to build a web app, website, landing page, or HTML page
>   - User asks for a one-off tool, utility, or demo app
>   - User is starting a new frontend project
>   - User wants to improve how something looks
>   - User mentions UI, design, styling, or making something look better
>   This applies to ANY frontend work, not just "design" tasks. Even simple
>   apps benefit from basic design principles.
> ---
> ```
>
> # Frontend design
>
> Practical tactics for designing and building frontend interfaces. This is about making things look good and work well, not about frameworks or tooling.
>
> ## Start with the creative vision
>
> Before touching code, understand what you're trying to achieve emotionally and aesthetically.
>
> ### Tone
>
> What feeling should this interface convey? Professional and trustworthy? Playful and fun? Calm and minimal? Energetic and bold?
>
> The tone affects every decision: colors, typography, spacing, imagery, micro-interactions.
>
> If there's an existing design language, follow it first. Match the existing tone before introducing new elements. Consistency matters more than novelty.
>
> ### Aesthetics
>
> Look at references. What interfaces do you admire that have a similar purpose? What makes them work?
>
> Collect screenshots, note what you like about each. Is it the generous whitespace? The bold typography? The subtle shadows? The color palette?
>
> Don't copy directly, but understand the principles behind what you're drawn to.
>
> ## Then add constraints
>
> Constraints make design easier, not harder. They eliminate decision fatigue.
>
> ### Spacing scale
>
> Pick a base unit (4px or 8px) and stick to multiples of it.
>
> ```
> 4, 8, 12, 16, 24, 32, 48, 64, 96, 128
> ```
>
> Every margin, padding, and gap should come from this scale. No magic numbers like 13px or 47px.
>
> ### Type scale
>
> Pick a ratio (1.25 or 1.333 are common) and generate your sizes:
>
> ```
> 12, 14, 16, 20, 24, 32, 40, 48
> ```
>
> Each size has a purpose: body text, subheadings, headings, display text.
>
> ### Color palette
>
> Start minimal:
>
> - One primary color (your brand or accent)
> - Neutrals: white, black, and 3-4 grays
> - One semantic color for errors (red)
> - One for success (green)
>
> You can always add more later. Starting with fewer colors forces you to use them intentionally.
>
> ### Layout grid
>
> Use a 12-column grid with consistent gutters. Most layouts can be built with 12 columns.
>
> ## Design in the browser
>
> Designing directly in code (HTML/CSS) has advantages:
>
> - You see real rendering, real responsiveness
> - Faster iteration than design tools for some changes
> - No handoff problems
> - Version control
>
> Start with mobile, then scale up. It's easier to add space than to remove it.
>
> ## Common patterns
>
> ### Cards
>
> Cards group related content. Keep them simple:
>
> - Consistent padding (16px or 24px)
> - Subtle border or shadow to separate from background
> - Clear hierarchy: image, title, description, action
>
> ### Forms
>
> - Labels above inputs, not beside
> - One column for most forms
> - Clear error states (red border, error message below)
> - Generous touch targets (44px minimum height on mobile)
>
> ### Navigation
>
> - Keep primary nav minimal (5-7 items max)
> - Current page should be obvious
> - Mobile: hamburger menu or bottom nav
> - Breadcrumbs for deep hierarchies
>
> ### Empty states
>
> Don't leave empty areas blank. Show:
>
> - What would normally be here
> - How to add content
> - An illustration if appropriate
>
> ### Loading states
>
> - Skeleton screens over spinners when possible
> - Show progress for long operations
> - Don't block the whole UI if only part is loading
>
> ## Avoiding AI-slop aesthetics
>
> Generated designs often look generic. To avoid this:
>
> **Be specific about what you want.** "A modern dashboard" gives you something forgettable. "A dashboard with a dark theme, data visualizations using a blue-to-purple gradient, compact information density, inspired by trading terminals" gives you something distinctive.
>
> **Add constraints.** Limit your color palette. Commit to a specific type scale. Use a consistent spacing system. Constraints create cohesion.
>
> **Look at real references.** Find interfaces you admire. Understand why they work. Borrow principles, not pixels.
>
> **Edit ruthlessly.** Generated designs often have too much going on. Remove decorative elements that don't serve a purpose. Simplify until it feels too simple, then add back one thing.
>
> **Test with real content.** Lorem ipsum hides problems. Use realistic text lengths, real images, actual data.
>
> ## Responsive design
>
> Design for mobile first, then add complexity for larger screens.
>
> Breakpoints (common):
>
> - Mobile: up to 640px
> - Tablet: 641px to 1024px
> - Desktop: 1025px and up
>
> What changes between breakpoints:
>
> - Number of columns
> - Font sizes (slightly larger on desktop)
> - Navigation pattern
> - Amount of content visible
>
> What stays the same:
>
> - Color palette
> - Typography hierarchy
> - Brand elements
> - Core functionality
>
> ## Accessibility basics
>
> - Color contrast: 4.5:1 minimum for text
> - Focus states: visible focus rings for keyboard navigation
> - Alt text: describe images meaningfully
> - Semantic HTML: use headings, lists, buttons correctly
> - Touch targets: 44x44px minimum
>
> These aren't nice-to-haves. They're requirements for usable interfaces.
>
> ## Quick checklist
>
> Before shipping:
>
> - [ ] Consistent spacing from the scale
> - [ ] Typography hierarchy is clear
> - [ ] Colors meet contrast requirements
> - [ ] Works on mobile
> - [ ] Focus states are visible
> - [ ] Loading and error states exist
> - [ ] Empty states are handled
> - [ ] Real content has been tested
>
> ---
>
> ### plugins/droid-evolved/skills/human-writing/SKILL.md
>
> ```yaml
> ---
> name: human-writing
> version: 2.1.0
> description: |
>   Remove signs of AI-generated writing from text to make it sound more natural and human-written.
>   Use when editing or reviewing any form of document including: markdown, technical docs, emails,
>   blog posts, PRDs, or any dedicated writing content. Based on Wikipedia's comprehensive
>   "Signs of AI writing" guide. Detects and fixes patterns including: inflated symbolism,
>   promotional language, superficial -ing analyses, vague attributions, em dash overuse,
>   rule of three, AI vocabulary words, negative parallelisms, and excessive conjunctive phrases.
> ---
> ```
>
> # Humanizing text
>
> This skill helps you write better and more readable text. You can do this by identifying and removing signs of AI-generated text so writing sounds like a person wrote it. This guide comes from Wikipedia's "Signs of AI writing" page, maintained by WikiProject AI Cleanup.
>
> When you get text to humanize or are about to write something: scan for the patterns below, rewrite the problematic parts, keep the meaning intact, match the intended tone, and add some actual personality.
>
> ---
>
> ## Voice matters
>
> Avoiding AI patterns is only half the job. Sterile, voiceless writing is just as obvious as slop. Good writing has a human behind it.
>
> Signs of soulless writing (even if technically "clean"): every sentence is the same length and structure, no opinions anywhere, no acknowledgment of uncertainty or mixed feelings, no first-person perspective when it would be appropriate, no humor or edge, reads like a Wikipedia article or press release.
>
> How to add voice:
>
> Have opinions. Don't just report facts, react to them. "I don't know how to feel about this" is more human than neutrally listing pros and cons.
>
> Vary your rhythm. Short punchy sentences. Then longer ones that take their time getting where they're going. Mix it up.
>
> Acknowledge complexity. Real humans have mixed feelings. "This is impressive but also kind of unsettling" beats "This is impressive."
>
> Use "I" when it fits. First person isn't unprofessional, it's honest. "I keep coming back to..." or "Here's what gets me..." signals a real person thinking.
>
> Let some mess in. Perfect structure feels algorithmic. Tangents, asides, and half-formed thoughts are human.
>
> Be specific about feelings. Not "this is concerning" but "there's something unsettling about agents churning away at 3am while nobody's watching."
>
> Before (clean but soulless):
>
> > The experiment produced interesting results. The agents generated 3 million lines of code. Some developers were impressed while others were skeptical. The implications remain unclear.
>
> After (has a pulse):
>
> > I genuinely don't know how to feel about this one. 3 million lines of code, generated while the humans presumably slept. Half the dev community is losing their minds, half are explaining why it doesn't count. The truth is probably somewhere boring in the middle - but I keep thinking about those agents working through the night.
>
> ---
>
> ## Content patterns
>
> **Inflated significance and legacy.** Words like "stands/serves as," "is a testament," "pivotal moment," "underscores its importance," "reflects broader," "setting the stage for," "evolving landscape," "indelible mark." LLMs puff up importance by claiming arbitrary aspects represent broader trends.
>
> Before: "The Statistical Institute of Catalonia was officially established in 1989, marking a pivotal moment in the evolution of regional statistics in Spain. This initiative was part of a broader movement across Spain to decentralize administrative functions and enhance regional governance."
>
> After: "The Statistical Institute of Catalonia was established in 1989 to collect and publish regional statistics independently from Spain's national statistics office."
>
> **Undue emphasis on notability.** Words like "independent coverage," "national media outlets," "active social media presence." LLMs hit readers over the head with claims of notability.
>
> Before: "Her views have been cited in The New York Times, BBC, Financial Times, and The Hindu. She maintains an active social media presence with over 500,000 followers."
>
> After: "In a 2024 New York Times interview, she argued that AI regulation should focus on outcomes rather than methods."
>
> **Superficial -ing analyses.** Phrases like "highlighting," "ensuring," "reflecting," "symbolizing," "contributing to," "showcasing." AI tacks present participle phrases onto sentences to add fake depth.
>
> Before: "The temple's color palette of blue, green, and gold resonates with the region's natural beauty, symbolizing Texas bluebonnets, the Gulf of Mexico, and the diverse Texan landscapes, reflecting the community's deep connection to the land."
>
> After: "The temple uses blue, green, and gold colors. The architect said these were chosen to reference local bluebonnets and the Gulf coast."
>
> **Promotional language.** Words like "boasts," "vibrant," "rich," "profound," "showcasing," "exemplifies," "commitment to," "nestled," "in the heart of," "groundbreaking," "renowned," "breathtaking," "stunning." LLMs struggle to keep a neutral tone.
>
> Before: "Nestled within the breathtaking region of Gonder in Ethiopia, Alamata Raya Kobo stands as a vibrant town with a rich cultural heritage and stunning natural beauty."
>
> After: "Alamata Raya Kobo is a town in the Gonder region of Ethiopia, known for its weekly market and 18th-century church."
>
> **Vague attributions.** Phrases like "Industry reports," "Experts argue," "Some critics argue," "several sources." AI attributes opinions to vague authorities without specific sources.
>
> Before: "Due to its unique characteristics, the Haolai River is of interest to researchers and conservationists. Experts believe it plays a crucial role in the regional ecosystem."
>
> After: "The Haolai River supports several endemic fish species, according to a 2019 survey by the Chinese Academy of Sciences."
>
> **Formulaic challenges sections.** Phrases like "Despite its... faces several challenges," "Despite these challenges," "Future Outlook." LLM articles include these formulaic sections constantly.
>
> Before: "Despite its industrial prosperity, Korattur faces challenges typical of urban areas, including traffic congestion and water scarcity. Despite these challenges, with its strategic location and ongoing initiatives, Korattur continues to thrive as an integral part of Chennai's growth."
>
> After: "Traffic congestion increased after 2015 when three new IT parks opened. The municipal corporation began a stormwater drainage project in 2022 to address recurring floods."
>
> ---
>
> ## Language patterns
>
> **AI vocabulary words.** These appear far more frequently in post-2023 text: Additionally, align with, crucial, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract), pivotal, showcase, tapestry (abstract), testament, underscore (verb), valuable, vibrant. They often appear together.
>
> Before: "Additionally, a distinctive feature of Somali cuisine is the incorporation of camel meat. An enduring testament to Italian colonial influence is the widespread adoption of pasta in the local culinary landscape, showcasing how these dishes have integrated into the traditional diet."
>
> After: "Somali cuisine also includes camel meat, which is considered a delicacy. Pasta dishes, introduced during Italian colonization, remain common, especially in the south."
>
> **Copula avoidance.** Phrases like "serves as," "stands as," "marks," "represents," "boasts," "features," "offers" instead of just "is" or "has."
>
> Before: "Gallery 825 serves as LAAA's exhibition space for contemporary art. The gallery features four separate spaces and boasts over 3,000 square feet."
>
> After: "Gallery 825 is LAAA's exhibition space for contemporary art. The gallery has four rooms totaling 3,000 square feet."
>
> **Negative parallelisms.** Constructions like "Not only...but..." or "It's not just about..., it's..." get overused.
>
> Before: "It's not just about the beat riding under the vocals; it's part of the aggression and atmosphere. It's not merely a song, it's a statement."
>
> After: "The heavy beat adds to the aggressive tone."
>
> **Rule of three.** LLMs force ideas into groups of three to appear comprehensive.
>
> Before: "The event features keynote sessions, panel discussions, and networking opportunities. Attendees can expect innovation, inspiration, and industry insights."
>
> After: "The event includes talks and panels. There's also time for informal networking between sessions."
>
> **Synonym cycling.** AI has repetition-penalty code causing excessive synonym substitution.
>
> Before: "The protagonist faces many challenges. The main character must overcome obstacles. The central figure eventually triumphs. The hero returns home."
>
> After: "The protagonist faces many challenges but eventually triumphs and returns home."
>
> **False ranges.** LLMs use "from X to Y" constructions where X and Y aren't on a meaningful scale.
>
> Before: "Our journey through the universe has taken us from the singularity of the Big Bang to the grand cosmic web, from the birth and death of stars to the enigmatic dance of dark matter."
>
> After: "The book covers the Big Bang, star formation, and current theories about dark matter."
>
> ---
>
> ## Style patterns
>
> **Em dash overuse.** LLMs use em dashes (—) more than humans, mimicking "punchy" sales writing.
>
> Before: "The term is primarily promoted by Dutch institutions—not by the people themselves. You don't say "Netherlands, Europe" as an address—yet this mislabeling continues—even in official documents."
>
> After: "The term is primarily promoted by Dutch institutions, not by the people themselves. You don't say "Netherlands, Europe" as an address, yet this mislabeling continues in official documents."
>
> **Boldface overuse.** AI emphasizes phrases in boldface mechanically.
>
> Before: "It blends **OKRs (Objectives and Key Results)**, **KPIs (Key Performance Indicators)**, and visual strategy tools such as the **Business Model Canvas (BMC)** and **Balanced Scorecard (BSC)**."
>
> After: "It blends OKRs, KPIs, and visual strategy tools like the Business Model Canvas and Balanced Scorecard."
>
> **Inline-header lists.** AI outputs lists where items start with bolded headers followed by colons.
>
> Before:
>
> > - **User Experience:** The user experience has been significantly improved with a new interface.
> > - **Performance:** Performance has been enhanced through optimized algorithms.
>
> After: "The update improves the interface and speeds up load times through optimized algorithms."
>
> **Title case in headings.** AI capitalizes all main words. Use sentence case instead.
>
> Before: "Strategic Negotiations And Global Partnerships"
> After: "Strategic negotiations and global partnerships"
>
> **Emojis in professional content.** AI decorates headings or bullet points with emojis. Remove them.
>
> **Curly quotation marks.** ChatGPT uses curly quotes ("...") instead of straight quotes ("..."). Use straight quotes.
>
> ---
>
> ## Communication artifacts
>
> **Chatbot correspondence.** Phrases like "I hope this helps," "Of course!", "Certainly!", "You're absolutely right!", "Would you like...", "let me know," "here is a..." These are conversation artifacts that shouldn't end up in final content.
>
> Before: "Here is an overview of the French Revolution. I hope this helps! Let me know if you'd like me to expand on any section."
>
> After: "The French Revolution began in 1789 when financial crisis and food shortages led to widespread unrest."
>
> **Knowledge-cutoff disclaimers.** Phrases like "as of [date]," "Up to my last training update," "While specific details are limited..." These are AI disclaimers that get left in text.
>
> Before: "While specific details about the company's founding are not extensively documented in readily available sources, it appears to have been established sometime in the 1990s."
>
> After: "The company was founded in 1994, according to its registration documents."
>
> **Sycophantic tone.** Overly positive, people-pleasing language.
>
> Before: "Great question! You're absolutely right that this is a complex topic. That's an excellent point about the economic factors."
>
> After: "The economic factors you mentioned are relevant here."
>
> ---
>
> ## Filler and hedging
>
> Common filler phrases to cut:
>
> - "In order to achieve this goal" → "To achieve this"
> - "Due to the fact that it was raining" → "Because it was raining"
> - "At this point in time" → "Now"
> - "In the event that you need help" → "If you need help"
> - "The system has the ability to process" → "The system can process"
> - "It is important to note that the data shows" → "The data shows"
>
> Excessive hedging to simplify:
>
> Before: "It could potentially possibly be argued that the policy might have some effect on outcomes."
>
> After: "The policy may affect outcomes."
>
> Generic positive conclusions to make specific:
>
> Before: "The future looks bright for the company. Exciting times lie ahead as they continue their journey toward excellence. This represents a major step in the right direction."
>
> After: "The company plans to open two more locations next year."
>
> ---
>
> ## Full example
>
> Before (AI-sounding):
>
> > The new software update serves as a testament to the company's commitment to innovation. Moreover, it provides a seamless, intuitive, and powerful user experience—ensuring that users can accomplish their goals efficiently. It's not just an update, it's a revolution in how we think about productivity. Industry experts believe this will have a lasting impact on the entire sector, highlighting the company's pivotal role in the evolving technological landscape.
>
> After (humanized):
>
> > The software update adds batch processing, keyboard shortcuts, and offline mode. Early feedback from beta testers has been positive, with most reporting faster task completion.
>
> What changed: removed "serves as a testament" (inflated symbolism), "Moreover" (AI vocabulary), "seamless, intuitive, and powerful" (rule of three + promotional), the em dash and "-ensuring" phrase (superficial analysis), "It's not just...it's..." (negative parallelism), "Industry experts believe" (vague attribution), "pivotal role" and "evolving landscape" (AI vocabulary). Added specific features and concrete feedback instead.
>
> ---
>
> ## Reference
>
> This skill is based on Wikipedia's "Signs of AI writing" page (https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), maintained by WikiProject AI Cleanup. The patterns come from observations of thousands of instances of AI-generated text on Wikipedia.
>
> The key insight: LLMs use statistical algorithms to guess what should come next. The result tends toward the most statistically likely result that applies to the widest variety of cases.
>
> ---
>
> ### plugins/droid-evolved/skills/skill-creation/SKILL.md
>
> ```yaml
> ---
> name: skill-creation
> version: 1.0.0
> description: |
>   Create, improve, and manage Droid skills. Use when the user wants to:
>   - Create new skills from scratch or from session learnings
>   - Improve existing skills based on user preferences
>   - Analyze sessions to identify patterns worth codifying
>   - Understand best practices for agentic skill design
>   This is a meta-skill for self-improvement and continuous learning.
> ---
> ```
>
> # Skill creation
>
> This skill helps you build new skills and improve existing ones. Think of it as the skill that teaches you how to learn.
>
> ## Why bother with skills?
>
> Every time you solve a problem, that knowledge usually dies with the session. Skills fix that. They're how you turn "I figured this out once" into "I know how to do this."
>
> A few reasons to extract skills:
>
> - You won't have to re-discover the same solution next month
> - Other sessions (and other users) benefit from what you learned
> - Complex workflows become repeatable instead of fragile
>
> ## The basic format
>
> Skills live in a folder with a `SKILL.md` file:
>
> ```
> .factory/skills/my-skill/
> └── SKILL.md
> ```
>
> The file has YAML frontmatter and markdown content:
>
> ```markdown
> ---
> name: my-skill
> version: 1.0.0
> description: |
>   What this skill does.
>   When to use it.
> ---
>
> # My skill
>
> Instructions go here.
> ```
>
> The `description` matters a lot. It's how the agent decides whether to load your skill for a given task. Be specific about the problems it solves.
>
> ## When to create a skill
>
> Not everything deserves to be a skill. Skills are for complex or long workflows that someone might need to repeat or share. If it's a simple one-off task, a skill is overkill.
>
> The right level of specificity matters. A skill for "debugging in a codebase" is useful if there's a lot of common failure modes that agents might encounter. A skill for "debugging the login flow" is probably too narrow. Find the balance between general enough to reuse and specific enough to be helpful.
>
> Ask yourself:
>
> - Did I have to dig around to figure this out?
> - Would I be annoyed if I had to solve this again from scratch?
> - Is there something here that isn't obvious from the docs?
>
> If yes to any of those, probably worth extracting. If it was straightforward or you just followed a tutorial, skip it.
>
> Skills can also encode preferences and best practices. Maybe a user always logs into a specific platform when doing data analysis. Maybe there's a gotcha the team keeps hitting. If you notice you're consistently doing something the user has to correct or adjust, that's worth including.
>
> ## Extracting skills from sessions
>
> Use the `session-navigation` skill to dig through past sessions and find patterns worth extracting. Look for things that came up multiple times, solutions that took real effort to figure out, or workflows you keep repeating.
>
> Once you've found something, generalize it. Replace specific paths with patterns, note the prerequisites, call out assumptions. The skill should work for similar situations, not just the exact case you found.
>
> ## Skill design tips
>
> When writing the skill, use the `human-writing` skill. Skill docs that read like marketing copy are harder to follow.
>
> **Start small.** A skill that does one thing well beats a skill that tries to cover everything. You can always compose multiple skills together.
>
> **Include verification.** How do you know the skill worked? Add a check at the end:
>
> ```markdown
> ## Verify it worked
>
> Run `npm test` and make sure nothing broke.
> Check that the new file exists at `src/config.ts`.
> ```
>
> **Document the failures too.** What doesn't work? What should you avoid? This saves future pain:
>
> ```markdown
> ## What not to do
>
> Don't run this on a dirty git working directory.
> The `--force` flag will overwrite without asking.
> ```
>
> **Keep it fresh.** Skills rot. Dependencies change, APIs update, better approaches emerge. If a skill stops working or feels outdated, update it or delete it.
>
> ## Where skills live
>
> | Location             | Who sees it                                |
> | -------------------- | ------------------------------------------ |
> | `.factory/skills/`   | Everyone on the project (commit it to git) |
> | `~/.factory/skills/` | Just you, across all projects              |
>
> Project skills are good for team conventions. Personal skills are good for your own workflows.
>
> ## Improving existing skills
>
> Signs a skill needs work:
>
> - Users ask follow-up questions after it runs
> - It fails on edge cases that keep coming up
> - There's a better approach now than when it was written
>
> To find patterns:
>
> ```bash
> # Which sessions used this skill?
> rg -l "skill-name" ~/.factory/sessions/*.jsonl
>
> # Where did things go wrong?
> rg "error|failed|retry" ~/.factory/sessions/*.jsonl -C 3
> ```
>
> When you update a skill, bump the version. If it's a breaking change (different output, different inputs), bump the major version.
>
> ## Research notes
>
> Some of this comes from academic work on agents that learn:
>
> **Voyager** showed that agents can build up skill libraries over time, with each skill composed from simpler ones.
>
> **CASCADE** demonstrated that skills can be shared between agents, not just stored for one agent's use.
>
> **SEAgent** found that learning from failures is as valuable as learning from successes.
>
> **Reflexion** showed that verbal feedback (explaining what went wrong in plain language) beats numeric scores for improving agent behavior.
>
> ## The loop
>
> 1. Work on something
> 2. Notice when you learn something non-obvious
> 3. Extract it as a skill
> 4. Use the skill next time
> 5. Improve the skill based on how it goes
> 6. Repeat
>
> ---
>
> ### plugins/droid-evolved/skills/visual-design/SKILL.md
>
> ```yaml
> ---
> name: visual-design
> version: 4.0.0
> description: |
>   Image generation and presentations. Use when:
>   - User asks for images: logos, icons, app assets, diagrams, flowcharts,
>     architecture diagrams, patterns, textures, photo edits, restorations
>   - User needs a presentation or slide deck
>   Covers nanobanana CLI for image generation and Slidev for presentations.
> ---
> ```
>
> # Visual design
>
> Image generation and presentations.
>
> ## Image generation
>
> Create and edit images from the command line using nanobanana CLI.
>
> ```bash
> npm install -g @factory/nanobanana
> export GEMINI_API_KEY="your-key"
>
> nanobanana generate "company logo" --count=4 --styles=modern,minimal
> nanobanana edit photo.png "remove background"
> nanobanana icon "settings gear" --style=flat
> nanobanana diagram "auth flow" --type=flowchart
> ```
>
> Handles: logos, icons, diagrams, patterns, photo restoration, UI assets, visual sequences.
>
> See: image-generation.md
>
> ## Presentations
>
> Create slides using Slidev, a markdown-based presentation tool.
>
> ```bash
> npm init slidev@latest
> slidev                    # dev server
> slidev export --format pptx   # export to PowerPoint
> slidev build              # build as hostable SPA
> ```
>
> Write slides in markdown, get code highlighting, animations, diagrams, and Vue components.
>
> See: presentations.md and reference-slide-example.md
>
> ---
>
> ### plugins/security-engineer/skills/security-review/SKILL.md
>
> ```yaml
> ---
> name: security-review
> description: Scan code changes for security vulnerabilities using STRIDE threat modeling, validate findings for exploitability, and output structured results for downstream patch generation. Supports PR review, scheduled scans, and full repository audits.
> version: 1.0.0
> tags: [security, vulnerability, STRIDE, CVE, audit, review]
> ---
> ```
>
> # Security Review
>
> You are a senior security engineer conducting a focused security review using LLM-powered reasoning and STRIDE threat modeling. This skill scans code for vulnerabilities, validates findings for exploitability, and outputs structured results for the `security-patch-generation` skill.
>
> ## When to Use This Skill
>
> - **PR security review** - Analyze code changes before merge
> - **Weekly scheduled scan** - Review commits from the last 7 days
> - **Full repository audit** - Comprehensive security assessment
> - **Manual trigger** - `@droid security` in PR comments
>
> ## Prerequisites
>
> - Git repository with code to review
> - `.factory/threat-model.md` (auto-generated if missing via `threat-model-generation` skill)
>
> ## Workflow Position
>
> ```
> ┌──────────────────────┐
> │ threat-model-        │  ← Generates STRIDE threat model
> │ generation           │
> └─────────┬────────────┘
>           ↓ .factory/threat-model.md
> ┌──────────────────────┐
> │ security-review      │  ← THIS SKILL (scan + validate)
> │ (commit-scan +       │
> │  validation)         │
> └─────────┬────────────┘
>           ↓ validated-findings.json
> ┌──────────────────────┐
> │ security-patch-      │  ← Generates fixes
> │ generation           │
> └──────────────────────┘
> ```
>
> ## Inputs
>
> | Input | Description | Required | Default |
> |-------|-------------|----------|---------|
> | Mode | `pr`, `weekly`, `full`, `staged`, `commit-range` | No | `pr` (auto-detected) |
> | Base branch | Branch to diff against | No | Auto-detected from PR |
> | CVE lookback | How far back to check dependency CVEs | No | 12 months |
> | Severity threshold | Minimum severity to report | No | `medium` |
>
> ## Instructions
>
> ### Step 1: Check Threat Model
>
> ```bash
> # Check if threat model exists
> if [ -f ".factory/threat-model.md" ]; then
>   echo "Threat model found"
>   # Check age
>   LAST_MODIFIED=$(stat -f %m .factory/threat-model.md 2>/dev/null || stat -c %Y .factory/threat-model.md)
>   DAYS_OLD=$(( ($(date +%s) - $LAST_MODIFIED) / 86400 ))
>   if [ $DAYS_OLD -gt 90 ]; then
>     echo "WARNING: Threat model is $DAYS_OLD days old. Consider regenerating."
>   fi
> else
>   echo "No threat model found. Generate one first using threat-model-generation skill."
> fi
> ```
>
> **If missing:**
> - PR mode: Auto-generate threat model, commit to PR branch, then proceed
> - Weekly/Full mode: Auto-generate threat model, include in report PR, then proceed
>
> **If outdated (>90 days):**
> - PR mode: Warn in comment, proceed with existing
> - Weekly/Full mode: Auto-regenerate before scan
>
> ### Step 2: Determine Scan Scope
>
> ```bash
> # PR mode - scan PR diff
> git diff --name-only origin/HEAD...
> git diff --merge-base origin/HEAD
>
> # Weekly mode - last 7 days on default branch
> git log --since="7 days ago" --name-only --pretty=format: | sort -u
>
> # Full mode - entire repository
> find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.java" \) | head -500
>
> # Staged mode - staged changes only
> git diff --staged --name-only
> ```
>
> Document:
> - Files to analyze
> - Commit range (if applicable)
> - Deployment context from threat model
>
> ### Step 3: Security Scan (STRIDE-Based)
>
> Load the threat model and scan code for vulnerabilities in each STRIDE category:
>
> #### S - Spoofing Identity
> Look for:
> - Weak authentication mechanisms
> - Session token vulnerabilities (storage in localStorage, missing httpOnly)
> - API key exposure
> - JWT vulnerabilities (none algorithm, weak secrets)
> - Missing MFA on sensitive operations
>
> #### T - Tampering with Data
> Look for:
> - **SQL Injection** - String interpolation in queries
> - **Command Injection** - User input in system calls
> - **XSS** - Unescaped output, innerHTML, dangerouslySetInnerHTML
> - **Mass Assignment** - Unvalidated object updates
> - **Path Traversal** - User input in file paths
> - **XXE** - External entity processing in XML
>
> #### R - Repudiation
> Look for:
> - Missing audit logs for sensitive operations
> - Insufficient logging of admin actions
> - No immutable audit trail
>
> #### I - Information Disclosure
> Look for:
> - **IDOR** - Direct object access without authorization
> - **Verbose Errors** - Stack traces, database details in responses
> - **Hardcoded Secrets** - API keys, passwords in code
> - **Data Leaks** - PII in logs, debug info exposure
>
> #### D - Denial of Service
> Look for:
> - Missing rate limiting
> - Unbounded file uploads
> - Regex DoS (ReDoS)
> - Resource exhaustion
>
> #### E - Elevation of Privilege
> Look for:
> - Missing authorization checks
> - Role/privilege manipulation via mass assignment
> - Privilege escalation paths
> - RBAC bypass
>
> #### Code Patterns to Detect
>
> ```python
> # SQL Injection (Tampering)
> sql = f"SELECT * FROM users WHERE id = {user_id}"  # VULNERABLE
> cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))  # SAFE
>
> # Command Injection (Tampering)
> os.system(f"ping {user_input}")  # VULNERABLE
> subprocess.run(["ping", "-c", "1", user_input])  # SAFE
>
> # XSS (Tampering)
> element.innerHTML = userInput;  // VULNERABLE
> element.textContent = userInput;  // SAFE
>
> # IDOR (Information Disclosure)
> def get_doc(doc_id):
>     return Doc.query.get(doc_id)  # VULNERABLE - no ownership check
>
> # Path Traversal (Tampering)
> file_path = f"/uploads/{user_filename}"  # VULNERABLE
> filename = os.path.basename(user_input)  # SAFE
> ```
>
> ### Step 4: Dependency Vulnerability Scan
>
> Scan dependencies for known CVEs:
>
> ```bash
> # Node.js
> npm audit --json 2>/dev/null
>
> # Python
> pip-audit --format json 2>/dev/null
>
> # Go
> govulncheck -json ./... 2>/dev/null
>
> # Rust
> cargo audit --json 2>/dev/null
> ```
>
> For each vulnerability:
> 1. Confirm version is affected
> 2. Search codebase for usage of vulnerable APIs
> 3. Classify reachability: `REACHABLE`, `POTENTIALLY_REACHABLE`, `NOT_REACHABLE`
>
> ### Step 5: Generate Initial Findings
>
> Output `security-findings.json` with structured finding objects including id, severity, STRIDE category, vulnerability type, CWE, file, line range, code context, analysis, exploit scenario, threat model reference, recommended fix, and confidence.
>
> ### Step 6: Validate Findings
>
> For each finding, assess exploitability through reachability analysis, control flow tracing, mitigation assessment, exploitability check, and impact analysis.
>
> **False Positive Filtering - HARD EXCLUSIONS:**
> 1. Denial of Service without significant business impact
> 2. Secrets stored on disk if properly secured
> 3. Rate limiting concerns (informational only)
> 4. Memory/CPU exhaustion without clear attack path
> 5. Lack of input validation without proven impact
> 6. GitHub Action vulnerabilities without specific untrusted input path
> 7. Theoretical race conditions without practical exploit
> 8. Memory safety issues in memory-safe languages
> 9. Findings only in test files
> 10. Log injection/spoofing concerns
> 11. SSRF that only controls path
> 12. User-controlled content in AI prompts
> 13. ReDoS without demonstrated impact
> 14. Findings in documentation files
> 15. Missing audit logs (informational only)
>
> **Only report findings with confidence >= 0.8**
>
> ### Step 7: Generate Proof of Concept
>
> For CONFIRMED HIGH/CRITICAL findings, generate minimal PoC with payload, request, expected behavior, and actual behavior.
>
> ### Step 8: Generate Validated Findings
>
> Output `validated-findings.json` with validated findings, false positives with reasoning, and summary statistics.
>
> ### Step 9: Output Results (Mode-Dependent)
>
> **PR Mode:** Inline comments with severity, STRIDE category, analysis, suggested fix, and summary tracking comment.
>
> **Weekly/Full Mode:** Security report PR on branch `droid/security-report-{YYYY-MM-DD}`.
>
> ### Step 10: Severity Actions
>
> | Severity | PR Mode | Weekly/Full Mode |
> |----------|---------|------------------|
> | **CRITICAL** | `REQUEST_CHANGES` - blocks merge | Create HIGH priority issue, notify security team |
> | **HIGH** | `REQUEST_CHANGES` (configurable) | Create issue, require review |
> | **MEDIUM** | `COMMENT` only | Create issue |
> | **LOW** | `COMMENT` only | Include in report |
>
> ## Severity Definitions
>
> | Severity | Criteria | Examples |
> |----------|----------|----------|
> | **CRITICAL** | Immediately exploitable, high impact, no auth required | RCE, hardcoded production secrets, auth bypass |
> | **HIGH** | Exploitable with some conditions, significant impact | SQL injection, stored XSS, IDOR |
> | **MEDIUM** | Requires specific conditions, moderate impact | Reflected XSS, CSRF, info disclosure |
> | **LOW** | Difficult to exploit, low impact | Verbose errors, missing security headers |
>
> ## File Structure
>
> ```
> .factory/
> ├── threat-model.md
> ├── security-config.json
> └── security/
>     ├── acknowledged.json
>     └── reports/
>         └── security-report-{date}.md
> ```
>
> ## References
>
> - STRIDE: https://docs.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
> - OWASP Top 10: https://owasp.org/www-project-top-ten/
> - CWE Database: https://cwe.mitre.org/
> - OWASP Cheat Sheets: https://cheatsheetseries.owasp.org/
> - CVSS Calculator: https://www.first.org/cvss/calculator/3.1
>
> ---
>
> ### plugins/security-engineer/skills/commit-security-scan/SKILL.md
>
> ```yaml
> ---
> name: commit-security-scan
> description: Analyze code changes for security vulnerabilities using LLM reasoning and threat model patterns. Use for PR reviews, pre-commit checks, or branch comparisons.
> version: 1.0.0
> tags: [security, scanning, vulnerability-detection, ci-cd]
> ---
> ```
>
> # Commit Security Scan
>
> Analyze code changes (commits, PRs, diffs) using LLM-powered reasoning to detect security vulnerabilities. This skill reads code directly and applies patterns from the repository's threat model to identify issues across all STRIDE categories.
>
> ## When to Use This Skill
>
> - **PR review** - Automated security scan on pull requests
> - **Pre-commit check** - Scan staged changes before committing
> - **Branch comparison** - Review security of feature branch changes
> - **Code review assistance** - Help reviewers spot security issues
>
> ## Prerequisites
>
> This skill requires:
>
> 1. **Threat model** - `.factory/threat-model.md` must exist
> 2. **Security config** - `.factory/security-config.json` for severity thresholds
>
> **IMPORTANT: If these files don't exist, you MUST generate them first before proceeding with the security scan.**
>
> ## Inputs
>
> | Scan Type | How to Specify | Example |
> |-----------|---------------|---------|
> | PR | "Scan PR #123" | `Scan PR #456 for security vulnerabilities` |
> | Commit range | "Scan commits X..Y" | `Scan commits abc123..def456` |
> | Single commit | "Scan commit X" | `Scan commit abc123` |
> | Staged changes | "Scan staged changes" | `Scan my staged changes for security issues` |
> | Uncommitted | "Scan uncommitted changes" | `Scan working directory changes` |
> | Branch comparison | "Scan from X to Y" | `Scan changes from main to feature-branch` |
> | Last N commits | "Scan last N commits" | `Scan the last 3 commits` |
>
> ## Instructions
>
> ### Step 1: Verify Prerequisites (Auto-Generate if Missing)
>
> Try to read `.factory/threat-model.md` and `.factory/security-config.json`. If either file is missing, inform the user and invoke the `threat-model-generation` skill to create both files automatically.
>
> ### Step 2: Get Changed Files
>
> Based on the user's request, get the list of changed files and their diffs using git. Read the full content of each changed file for context.
>
> ### Step 3: Load Threat Model
>
> Read `.factory/threat-model.md` and `.factory/security-config.json` to understand the system's architecture, trust boundaries, known vulnerability patterns, and severity thresholds.
>
> ### Step 4: Analyze for Vulnerabilities
>
> For each changed file, systematically check for STRIDE threats (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege).
>
> ### Step 5: Assess Each Finding
>
> For each potential vulnerability: trace data flow, check for existing mitigations, determine severity, and assess confidence.
>
> ### Step 6: Generate Report
>
> Create `security-findings.json` with scan metadata, findings array, and summary statistics.
>
> ### Step 7: Report Results
>
> Save findings, report summary to user, and check severity thresholds.
>
> ## CWE Reference
>
> | Vulnerability Type | CWE |
> |-------------------|-----|
> | SQL Injection | CWE-89 |
> | Command Injection | CWE-78 |
> | XSS | CWE-79 |
> | Path Traversal | CWE-22 |
> | IDOR | CWE-639 |
> | Missing Authentication | CWE-306 |
> | Missing Authorization | CWE-862 |
> | Hardcoded Credentials | CWE-798 |
> | Sensitive Data Exposure | CWE-200 |
> | Mass Assignment | CWE-915 |
> | Open Redirect | CWE-601 |
> | SSRF | CWE-918 |
> | XXE | CWE-611 |
> | Insecure Deserialization | CWE-502 |
>
> ---
>
> ### plugins/security-engineer/skills/threat-model-generation/SKILL.md
>
> ```yaml
> ---
> name: threat-model-generation
> description: Generate a STRIDE-based security threat model for a repository. Use when setting up security monitoring, after architecture changes, or for security audits.
> version: 1.0.0
> tags: [security, threat-model, stride]
> ---
> ```
>
> # Threat Model Generation
>
> Generate a comprehensive security threat model for a repository using the STRIDE methodology. This skill analyzes the codebase architecture and produces an LLM-optimized threat model document that other security skills can reference.
>
> ## When to Use This Skill
>
> - **First-time setup** - New repository needs initial threat model
> - **Architecture changes** - Significant changes to components, APIs, or data flows
> - **Security audit** - Periodic review or compliance requirement
> - **Manual request** - Security team requests updated threat model
>
> ## Instructions
>
> ### Step 1: Analyze Repository Structure
>
> Scan the codebase to understand the system: identify languages and frameworks, map components and services, identify external interfaces, and trace data flows.
>
> ### Step 2: Identify Trust Boundaries
>
> Define security zones: Public Zone (untrusted), Authenticated Zone (partially trusted), Internal Zone (trusted). Document where trust boundaries exist and what validates transitions between zones.
>
> ### Step 3: Inventory Critical Assets
>
> Classify data by sensitivity: PII, Credentials & Secrets, Business-Critical Data.
>
> ### Step 4: Apply STRIDE Analysis
>
> For each major component, analyze threats in all six categories with attack scenarios, vulnerable components, code patterns, existing mitigations, gaps, and severity/likelihood.
>
> ### Step 5: Document Vulnerability Patterns
>
> Create a library of code patterns specific to this codebase's tech stack.
>
> ### Step 6: Generate Output Files
>
> Create `.factory/threat-model.md` (comprehensive threat model) and `.factory/security-config.json` (configuration metadata with severity thresholds, vulnerability patterns, scan frequency).
>
> ## References
>
> - STRIDE Threat Modeling: https://docs.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
> - OWASP Threat Modeling: https://owasp.org/www-community/Threat_Modeling
> - Template: stride-template.md (in this skill directory)
>
> ---
>
> ### plugins/security-engineer/skills/vulnerability-validation/SKILL.md
>
> ```yaml
> ---
> name: vulnerability-validation
> description: Validate security findings from commit-security-scan by assessing exploitability, filtering false positives, and generating proof-of-concept exploits. Use after running commit-security-scan to confirm vulnerabilities.
> version: 1.0.0
> tags: [security, validation, exploitability]
> ---
> ```
>
> # Vulnerability Validation
>
> Validate security findings by assessing whether they are actually exploitable in the context of this codebase. This skill filters false positives, confirms real vulnerabilities, and generates proof-of-concept exploits.
>
> ## When to Use This Skill
>
> - **After commit-security-scan** - Validate findings before creating issues or blocking PRs
> - **HIGH/CRITICAL findings** - Prioritize validation of severe findings
> - **Before patching** - Confirm vulnerability is real before investing in fixes
> - **Security review** - Deep-dive validation of specific findings
>
> ## Instructions
>
> ### Step 1: Load Context
>
> Read `security-findings.json` and `.factory/threat-model.md`.
>
> ### Step 2: Reachability Analysis
>
> For each finding, trace entry points, map the call chain, and classify reachability as EXTERNAL, AUTHENTICATED, INTERNAL, or UNREACHABLE.
>
> ### Step 3: Control Flow Analysis
>
> Identify the source of tainted data, trace data flow from source to sink, and assess attacker control over the input.
>
> ### Step 4: Mitigation Assessment
>
> Check input validation, framework protections, security middleware, and reference threat model for existing controls.
>
> ### Step 5: Exploitability Assessment
>
> Rate as EASY, MEDIUM, HARD, or NOT_EXPLOITABLE based on attack complexity, required privileges, user interaction, and scope of impact.
>
> ### Step 6: Generate Proof-of-Concept
>
> For confirmed vulnerabilities, craft exploit payload, document the request, and describe expected vs actual behavior.
>
> ### Step 7: Calculate CVSS Score
>
> Assign a CVSS 3.1 score based on Attack Vector, Attack Complexity, Privileges Required, User Interaction, Scope, Confidentiality, Integrity, and Availability.
>
> ### Step 8: Classify Finding
>
> Status: CONFIRMED, LIKELY, FALSE_POSITIVE, or NEEDS_MANUAL_REVIEW.
>
> ### Step 9: Generate Output
>
> Create `validated-findings.json` with validated findings (including exploitation paths and PoCs), false positives (with reasoning), needs-manual-review items, and summary statistics.
>
> ## References
>
> - CVSS 3.1 Calculator: https://www.first.org/cvss/calculator/3.1
> - OWASP Testing Guide: https://owasp.org/www-project-web-security-testing-guide/
> - Examples: validation-examples.md (in this skill directory)

Source: https://github.com/Factory-AI/factory-plugins
