---
created: 2026-03-02
description: Factory's Droid plugin system packages skills, slash commands, subagent definitions, lifecycle hooks, and MCP server configs into shareable directories distributed through Git-backed marketplaces with user, project, and org installation scopes.
source: https://docs.factory.ai/cli/configuration/plugins
---

## Key Takeaways

Factory's plugin architecture extends Droid through five component types — skills, commands, agents, hooks, and MCP servers — each with a distinct invocation model ranging from automatic model-triggered skills to user-invoked slash commands. This mirrors the pattern seen in [[Factory droid-action wraps agent execution into a GitHub Actions contract with structured inputs MCP tools and STRIDE security skills|droid-action's MCP tool integration]] where tools are surfaced as callable capabilities.

The plugin distribution model is Git-native: marketplaces are simply Git repositories containing plugin catalogs, and plugins are versioned by commit hash rather than semver. There is no version pinning — updates always pull latest. This is a deliberate simplicity trade-off that avoids dependency resolution complexity but sacrifices reproducibility.

Plugins install at three scopes (user, project, org) with scope determining both filesystem location and visibility. Project-scoped plugins live in `.factory/` and ship via git, making them automatically shared with teammates — similar to how [[Factory Droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access|droid exec's autonomy tiers]] are configured per-project.

Lifecycle hooks use a `PostToolUse` event model with regex matchers on tool names, allowing plugins to inject formatting, linting, or validation after file writes. The `${DROID_PLUGIN_ROOT}` variable enables portable script references within plugin directories.

The plugin format is explicitly interoperable with Claude Code plugins, confirming Factory's strategy of compatibility with the broader Claude ecosystem rather than a proprietary lock-in.

Team marketplaces can be auto-registered via `.factory/settings.json` with `extraKnownMarketplaces` and `enabledPlugins`, enabling zero-touch plugin provisioning for enterprise teams.

## External Resources

- [Factory official plugin marketplace](https://github.com/Factory-AI/factory-plugins) — curated plugins including droid-evolved and security-engineer
- [obra/superpowers](https://github.com/obra/superpowers) — community plugin for brainstorming, planning, and subagent-driven development
- [Enterprise Plugin Registry docs](https://docs.factory.ai/enterprise/enterprise-plugin-registry) — centralized control over approved plugins
- [Building plugins guide](https://docs.factory.ai/guides/building/building-plugins) — how to create plugins
- [Hooks reference](https://docs.factory.ai/reference/hooks-reference#plugin-hooks) — lifecycle hook details
- [Claude Code plugins documentation](https://code.claude.com/docs/en/plugins) — interoperable plugin format

## Original Content

> [!quote]- Source Material

> # Plugins
> 
> > Extend Droid with shareable packages of skills, commands, and tools.
> 
> Plugins let you extend Droid with custom functionality that can be shared across projects and teams. A plugin bundles skills, slash commands, agents, and MCP servers into a single, distributable package.
> 
> ## What are plugins?
> 
> Plugins are directories containing a manifest file (`.factory-plugin/plugin.json`) and optional components like skills, commands, and agents. Unlike standalone configuration in `.factory/`, plugins are designed for sharing and distribution.
> 
> **Plugin components:**
> 
> | Component       | Purpose                                           | Invocation                                |
> | --------------- | ------------------------------------------------- | ----------------------------------------- |
> | **Skills**      | Reusable capabilities with instructions and tools | Model-invoked automatically based on task |
> | **Commands**    | Slash commands for specific workflows             | User-invoked via `/command-name`          |
> | **Agents**      | Specialized subagent definitions                  | Called via Task tool                      |
> | **Hooks**       | Lifecycle event handlers                          | Automatic on matching events              |
> | **MCP Servers** | External tool integrations                        | Available as tools when plugin is active  |
> 
> ## When to use plugins vs standalone configuration
> 
> | Approach                               | Best for                                                                                        |
> | -------------------------------------- | ----------------------------------------------------------------------------------------------- |
> | **Standalone** (`.factory/` directory) | Personal workflows, project-specific customizations, quick experiments                          |
> | **Plugins**                            | Sharing with teammates, distributing to community, versioned releases, reusable across projects |
> 
> Start with standalone configuration in `.factory/` for quick iteration, then convert to a plugin when you're ready to share.
> 
> ## Managing plugins
> 
> Droid provides two ways to manage plugins:
> 
> ### Interactive UI (recommended)
> 
> Use the `/plugins` slash command to open the plugin manager:
> 
> ```
> /plugins
> ```
> 
> This opens a tabbed interface:
> 
> * **Browse** - View and install plugins from registered marketplaces
> * **Installed** - Manage installed plugins (view info, update, uninstall)
> * **Marketplaces** - Add, update, or remove marketplaces
> 
> **Navigation:**
> 
> * Left/Right arrows: Switch between tabs
> * Up/Down arrows: Navigate within a tab
> * Enter: Select/confirm
> * Escape: Go back or close
> 
> ### CLI commands (for scripting)
> 
> For automation, use CLI commands from your shell (not as slash commands):
> 
> ```bash
> # Marketplace management
> droid plugin marketplace add <url>
> droid plugin marketplace remove <name>
> droid plugin marketplace list
> droid plugin marketplace update [name]
> 
> # Plugin management
> droid plugin install <plugin@marketplace> [--scope user|project]
> droid plugin uninstall <plugin@marketplace> [--scope user|project]
> droid plugin update [plugin@marketplace] [--scope user|project]
> droid plugin list [--scope user|project]
> ```
> 
> Plugin IDs use the format `pluginName@marketplaceName` (e.g., `security-guidance@claude-plugins-official`).
> 
> ## Plugin structure
> 
> Every plugin follows this directory structure:
> 
> ```
> my-plugin/
> ├── .factory-plugin/
> │   └── plugin.json          # Plugin manifest (required)
> ├── commands/                 # Slash commands (optional)
> │   └── my-command.md
> ├── skills/                   # Agent skills (optional)
> │   └── my-skill/
> │       └── SKILL.md
> ├── droids/                   # Subagent definitions (optional)
> │   └── my-agent.md
> ├── mcp.json                  # MCP server configs (optional)
> └── README.md                 # Documentation
> ```
> 
> > **Warning:** Don't put `commands/`, `skills/`, `droids/`, or `hooks/` inside the `.factory-plugin/` directory. Only `plugin.json` goes inside `.factory-plugin/`. All other directories must be at the plugin root level.
> 
> ### Plugin hooks
> 
> Plugins can include hooks that execute at specific lifecycle events. Add a `hooks/` directory with a `hooks.json` file:
> 
> ```
> my-plugin/
> ├── .factory-plugin/
> │   └── plugin.json
> ├── hooks/
> │   ├── hooks.json         # Hook configuration
> │   └── my-script.sh       # Hook scripts
> └── ...
> ```
> 
> **hooks/hooks.json example:**
> 
> ```json
> {
>   "PostToolUse": [
>     {
>       "matcher": "Write|Edit",
>       "hooks": [
>         {
>           "type": "command",
>           "command": "${DROID_PLUGIN_ROOT}/hooks/format.sh"
>         }
>       ]
>     }
>   ]
> }
> ```
> 
> Use `${DROID_PLUGIN_ROOT}` to reference files within your plugin directory. This variable is expanded to the actual plugin path when the hook runs. See [Hooks reference](https://docs.factory.ai/reference/hooks-reference#plugin-hooks) for details.
> 
> ### Plugin manifest
> 
> The manifest at `.factory-plugin/plugin.json` defines your plugin's identity:
> 
> ```json
> {
>   "name": "my-plugin",
>   "description": "A helpful description of what this plugin does",
>   "version": "1.0.0",
>   "author": {
>     "name": "Your Name"
>   }
> }
> ```
> 
> | Field         | Purpose                                                  |
> | ------------- | -------------------------------------------------------- |
> | `name`        | Unique identifier for the plugin.                        |
> | `description` | Shown in the plugin manager when browsing or installing. |
> | `version`     | Track releases using semantic versioning.                |
> | `author`      | Optional. Helpful for attribution.                       |
> 
> ## Plugin scopes
> 
> When installing plugins, you choose an installation scope:
> 
> | Scope       | Location              | Visibility                         |
> | ----------- | --------------------- | ---------------------------------- |
> | **User**    | `~/.factory/`         | Available across all your projects |
> | **Project** | `<project>/.factory/` | Shared with teammates via git      |
> 
> > **Note:** **Org scope**: Plugins enabled via organization managed settings are automatically installed with `org` scope. You cannot manually set org scope.
> 
> A plugin can only exist at one scope. To change scope, uninstall first and reinstall.
> 
> ## Version tracking
> 
> Plugins are versioned by Git commit hash, not semantic version. When you update a plugin, Droid fetches the latest commit from the marketplace repository.
> 
> > **Note:** Version pinning is not supported. Updates always fetch the latest version from the marketplace.
> 
> ## Marketplaces
> 
> Marketplaces are catalogs of plugins that you can browse and install from.
> 
> ### Adding marketplaces
> 
> Via UI: `/plugins` → Marketplaces tab → "Add new marketplace" → enter URL
> 
> Via CLI:
> 
> ```bash
> # From GitHub
> droid plugin marketplace add https://github.com/owner/repo
> 
> # From other Git hosts
> droid plugin marketplace add https://gitlab.com/company/plugins.git
> 
> # From local path (for development)
> droid plugin marketplace add /path/to/local/marketplace
> ```
> 
> ### Managing marketplaces
> 
> Via UI: `/plugins` → Marketplaces tab → select marketplace → choose action (Update, Disable auto-update, Delete)
> 
> Via CLI:
> 
> ```bash
> droid plugin marketplace list
> droid plugin marketplace update [marketplace-name]
> droid plugin marketplace remove <marketplace-name>
> ```
> 
> > **Note:** Removing a marketplace does not uninstall plugins from that marketplace. Installed plugins remain functional from cache.
> 
> ### Team marketplaces
> 
> Configure automatic marketplace and plugin installation by adding to `.factory/settings.json`:
> 
> ```json
> {
>   "extraKnownMarketplaces": {
>     "your-org-internal-plugins": {
>       "source": {
>         "source": "github",
>         "repo": "your-org/internal-plugins"
>       }
>     }
>   },
>   "enabledPlugins": {
>     "code-standards@your-org-internal-plugins": true
>   }
> }
> ```
> 
> When Droid starts, it automatically:
> 
> 1. Registers any marketplaces from `extraKnownMarketplaces` that aren't already registered
> 2. Installs any plugins from `enabledPlugins` that aren't already installed
> 
> The installation scope depends on where the setting is defined:
> 
> * Org-managed settings → `org` scope
> * User settings → `user` scope
> * Project settings → `project` scope
> 
> ## Discovering plugins
> 
> ### Official Factory plugins
> 
> Factory maintains an official plugin marketplace at `Factory-AI/factory-plugins` with curated plugins.
> 
> Add via `/plugins` UI or CLI:
> 
> ```bash
> droid plugin marketplace add https://github.com/Factory-AI/factory-plugins
> ```
> 
> **Available plugins:**
> 
> | Plugin                | Description                                                                                                                           |
> | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
> | **droid-evolved**     | Skills for continuous learning: session navigation, human writing, skill creation, visual design, frontend design, browser automation |
> | **security-engineer** | Security review, threat modeling, commit scanning, and vulnerability validation                                                       |
> 
> Install via `/plugins` UI (Browse tab) or CLI:
> 
> ```bash
> droid plugin install droid-evolved@factory-plugins
> droid plugin install security-engineer@factory-plugins
> ```
> 
> ### Community plugins
> 
> | Plugin          | Description                                                                                          | Source             |
> | --------------- | ---------------------------------------------------------------------------------------------------- | ------------------ |
> | **superpowers** | Complete software development workflow with brainstorming, planning, and subagent-driven development | `obra/superpowers` |
> 
> ### Enterprise Plugin Registry
> 
> For organizations that need centralized control over approved plugins, see [Enterprise Plugin Registry](https://docs.factory.ai/enterprise/enterprise-plugin-registry). This allows you to:
> 
> * Maintain a private marketplace of approved plugins
> * Pre-install mandatory plugins for all users
> * Organize plugins by team, role, or capability
> 
> ### Claude Code compatibility
> 
> Droid is compatible with plugins built for Claude Code. If you find a Claude Code plugin you'd like to use, you can install it directly - the plugin format is interoperable. See the [Claude Code plugins documentation](https://code.claude.com/docs/en/plugins) for more details.
> 
> ## Next steps
> 
> - [Building plugins](https://docs.factory.ai/guides/building/building-plugins) — Learn how to create your own plugins with skills and commands.
> - [Skills](https://docs.factory.ai/cli/configuration/skills) — Understand how skills work and how to create them.
> - [Custom commands](https://docs.factory.ai/cli/configuration/custom-slash-commands) — Create user-invoked slash commands.
> - [Custom Droids](https://docs.factory.ai/cli/configuration/custom-droids) — Create specialized subagents for your plugins.

[Source](https://docs.factory.ai/cli/configuration/plugins)
