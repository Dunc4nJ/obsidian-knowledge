---
created: 2026-02-25
type: project-doc
description: "Guide for connecting to Morph's edit_file and warpgrep_codebase_search tools via MCP in Claude Code, Codex, Cursor, and other clients."
---
# MCP Integration

Connect to Morph's blazing-fast file editing via Model Context Protocol

## [​](#overview) Overview

Connect to Morph's models via MCP. Works with Claude Code, Codex, Cursor, and other MCP clients.
**Two modes:**

* **Default** (recommended): `edit_file` and 'warpgrep\_codebase\_search' via environment variable `ENABLED_TOOLS="edit_file", "warpgrep_codebase_search"`
* **Custom** : If you want more control over the tools used, you can specify any one of the two available tools

## [​](#quick-install-claude-code) Quick Install (Claude Code)

Run this command in your terminal:

```
claude mcp add morph —scope user -e MORPH_API_KEY=YOUR_API_KEY — npx -y @morphllm/morphmcp
```

**Logged in?** Your API key will auto-fill above. Otherwise, get it from your [dashboard](https://morphllm.com/dashboard/api-keys).

## [​](#installation-all-clients) Installation (All Clients)

1

1. Get Your API Key

Get your API key from the [dashboard](https://morphllm.com/dashboard/api-keys).

2

2. Configure Your MCP Client

**Not logged in?** Replace the API key placeholder in the commands below with your actual key from the [dashboard](https://morphllm.com/dashboard/api-keys).

* Claude Code
* Codex
* Cursor
* Claude Desktop
* VS Code
* Manual

**One-liner Installation (Recommended)**:

```
claude mcp add filesystem-with-morph --scope user -e MORPH_API_KEY=YOUR_API_KEY -- npx -y @morphllm/morphmcp
```

**Configure Claude to prefer Morph**: Add this to your global Claude config:

```
mkdir -p ~/.claude && echo "Fast Apply: IMPORTANT: Use \`edit_file\` over \`str_replace\` or full file writes. It works with partial code snippets—no need for full file content.
Warp Grep: warp-grep is a subagent that takes in a search string and tries to find relevant context. Best practice is to use it at the beginning of codebase explorations to fast track finding relevant files/lines. Do not use it to pin point keywords, but use it for broader semantic queries. \"Find the XYZ flow\", \"How does XYZ work\", \"Where is XYZ handled?\", \"Where is <error message> coming from?\"" >> ~/.claude/CLAUDE.md
```

**Manual Config File Method**:Create or edit `.claude.json` in your workspace:

```
{
  "mcpServers": {
    "filesystem-with-morph": {
      "env": {
        "MORPH_API_KEY": "YOUR_API_KEY"
      },
      "command": "npx -y @morphllm/morphmcp",
      "args": []
    }
  }
}
```

**CLI Installation (Recommended)**:

```
# Add Morph MCP server to Codex
codex mcp add filesystem-with-morph -e MORPH_API_KEY=YOUR_API_KEY -- npx -y @morphllm/morphmcp
```

**Manual Config File**:Add to `~/.codex/config.toml`:

```
[mcp_servers.filesystem-with-morph]
env = { "MORPH_API_KEY" = "YOUR_API_KEY" }
command = "npx -y @morphllm/morphmcp"
args = []
# Optional: adjust timeouts
startup_timeout_sec = 10
tool_timeout_sec = 60
```

**CLI Management**: Use `codex mcp list` to see configured servers and `codex mcp remove filesystem-with-morph` to remove.

Add to your `AGENTS.md`:

```
Fast Apply: IMPORTANT: Use `edit_file` over `str_replace` or full file writes. It works with partial code snippets—no need for full file content.
Warp Grep: warp-grep is a subagent that takes in a search string and tries to find relevant context. Best practice is to use it at the beginning of codebase explorations to fast track finding relevant files/lines. Do not use it to pin point keywords, but use it for broader semantic queries. "Find the XYZ flow", "How does XYZ work", "Where is XYZ handled?", "Where is <error message> coming from?"
```

Add to your Cursor MCP by clicking this button:  ![Install MCP Server](https://cursor.com/deeplink/mcp-install-light.svg)OR add to your Cursor MCP config file:**Location**: `~/.cursor/mcp.json`

```
{
  "mcpServers": {
    "morph-mcp": {
      "env": {
        "MORPH_API_KEY": "YOUR_API_KEY"
      },
      "command": "npx -y @morphllm/morphmcp",
      "args": []
    }
  }
}
```

**Global Config**: This configuration works across all your projects automatically. The MCP server detects workspace boundaries via `.git`, `package.json`, and other project indicators.

**Make Cursor use Morph tools!** Add this to your system prompt in **Settings → Rules for AI**:

```
Fast Apply: IMPORTANT: Use `edit_file` over `str_replace` or full file writes. It works with partial code snippets—no need for full file content.
Warp Grep: warp-grep is a subagent that takes in a search string and tries to find relevant context. Best practice is to use it at the beginning of codebase explorations to fast track finding relevant files/lines. Do not use it to pin point keywords, but use it for broader semantic queries. "Find the XYZ flow", "How does XYZ work", "Where is XYZ handled?", "Where is <error message> coming from?"
```

Add to your Claude Desktop config file:**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

```
{
  "mcpServers": {
    "filesystem-with-morph": {
      "env": {
        "MORPH_API_KEY": "YOUR_API_KEY"
      },
      "command": "npx -y @morphllm/morphmcp",
      "args": []
    }
  }
}
```

**Restart Required**: Completely quit and restart Claude Desktop to load the new configuration.

Add to your project instructions:

```
Fast Apply: IMPORTANT: Use `edit_file` over `str_replace` or full file writes. It works with partial code snippets—no need for full file content.
Warp Grep: warp-grep is a subagent that takes in a search string and tries to find relevant context. Best practice is to use it at the beginning of codebase explorations to fast track finding relevant files/lines. Do not use it to pin point keywords, but use it for broader semantic queries. "Find the XYZ flow", "How does XYZ work", "Where is XYZ handled?", "Where is <error message> coming from?"
```

**CLI Installation (Recommended)**:

```
code --add-mcp '{"name":"morph-mcp","command":"npx","args":["-y","@morphllm/morphmcp"],"envVars":{"MORPH_API_KEY":"YOUR_API_KEY"}}'
```

Or use the Command Palette: run `MCP: Add Server`, enter the server details, and select **Global** to save to your user profile.**Manual Config File**:Run `MCP: Open User Configuration` from the Command Palette, or add to your user-level `mcp.json`:

```
{
  "mcpServers": {
    "filesystem-with-morph": {
      "env": {
        "MORPH_API_KEY": "YOUR_API_KEY"
      },
      "command": "npx -y @morphllm/morphmcp",
      "args": []
    }
  }
}
```

Add to your `.github/copilot-instructions.md`:

```
Fast Apply: IMPORTANT: Use `edit_file` over `str_replace` or full file writes. It works with partial code snippets—no need for full file content.
Warp Grep: warp-grep is a subagent that takes in a search string and tries to find relevant context. Best practice is to use it at the beginning of codebase explorations to fast track finding relevant files/lines. Do not use it to pin point keywords, but use it for broader semantic queries. "Find the XYZ flow", "How does XYZ work", "Where is XYZ handled?", "Where is <error message> coming from?"
```

Run the MCP server directly:

```
export MORPH_API_KEY="YOUR_API_KEY"
export ENABLED_TOOLS="edit_file,warpgrep_codebase_search"
npx -y @morphllm/morphmcp
```

3

3. Test Installation

**Claude Code**: Type `/mcp` and `/tools` to see Morph's `edit_file` tool
**Codex**: Run `codex mcp list` to verify server is configured, then make edit requests
**Cursor/VS Code**: Make any code edit request - should use Morph automatically
**Manual**: Check server logs show "MCP Server started successfully"

## [​](#configuration) Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `MORPH_API_KEY` | Required | Your API key |
| `ENABLED_TOOLS` | `"edit_file,warpgrep_codebase_search"` | Comma-separated list of tools, or `"all"` for full filesystem access |
| `WORKSPACE_MODE` | `"true"` | Auto workspace detection |
| `DEBUG` | `"false"` | Debug logging |

### [​](#advanced-configuration) Advanced Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `MORPH_API_URL` | `https://api.morphllm.com` | Override the Morph API base URL (for proxies) |
| `MORPH_WARP_GREP_TIMEOUT` | `30000` | Timeout for Warp Grep model calls in milliseconds |

**Custom API endpoint** — For enterprise deployments or custom authentication flows:

```
{
  "mcpServers": {
    "morph-mcp": {
      "env": {
        "MORPH_API_KEY": "<user-jwt-token>",
        "MORPH_API_URL": "https://your-proxy.example.com"
      },
      "command": "npx -y @morphllm/morphmcp",
      "args": []
    }
  }
}
```

Your proxy receives requests to `/v1/chat/completions` with the token in the `Authorization: Bearer` header. Forward these to `https://api.morphllm.com/v1/chat/completions` after handling auth/billing.
**Warp Grep timeout** — Increase for large codebases or slow networks:

```
{
  "mcpServers": {
    "morph-mcp": {
      "env": {
        "MORPH_API_KEY": "sk-xxx",
        "MORPH_WARP_GREP_TIMEOUT": "60000"
      },
      "command": "npx -y @morphllm/morphmcp",
      "args": []
    }
  }
}
```

## [​](#available-tools) Available Tools

### [​](#morph-powered-tools-default) Morph-Powered Tools (Default)

**`edit_file`** - 10,500+ tokens/sec code editing via Morph Apply
**`warpgrep_codebase_search`** - up to 8 parallel tool calls per turn, a smart, fast search sub agent.

## [​](#troubleshooting) Troubleshooting

**Server won't start**: Check API key, Node.js 16+, run `npm cache clean --force`
**Tools missing**: Restart client, validate JSON config
**Workspace issues**: Add `.git` or `package.json`, or set `WORKSPACE_MODE="false"`
**Slow performance**: Use `edit_file` over `write_file`, check network to api.morphllm.com

## [​](#performance-optimization) Performance Optimization

### [​](#best-practices) Best Practices

1. **Use `edit_file` for modifications**: Much faster than reading + writing entire files
2. **Minimize edit scope**: Include only the sections that need changes
3. **Batch related edits**: Make multiple changes in a single `edit_file` call

### [​](#performance-comparison) Performance Comparison

| Method | Speed | Use Case |
| --- | --- | --- |
| `edit_file` (Morph) | ~11 seconds | Code modifications, updates |
| Search & replace | ~20 seconds | Simple text substitutions |
| Traditional read/write | ~60 seconds | Full file rewrites |
