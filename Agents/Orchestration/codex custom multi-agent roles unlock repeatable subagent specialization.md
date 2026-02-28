---
created: 2026-02-19
description: Codex 0.102.0 introduced custom multi-agent roles with configurable models, reasoning, permissions, system prompts, and thread limits — enabling repeatable subagent specialization beyond the three built-in roles.
source: https://x.com/LLMJunky/status/2024152021436121220
type: learning
---

## Key Takeaways

Custom multi-agent roles in Codex let you define **repeatable, specialized subagents** with their own model, reasoning level, permissions, system prompt, and even MCP servers — moving beyond the three built-in roles (default, explorer, worker). This is a significant step toward the kind of [[orchestration architecture determines multi-agent investment quality|orchestration architecture]] that determines output quality more than raw agent count.

The configuration is hierarchical (global `~/.codex/` → project `.codex/` → subfolder), mirroring how AGENTS files already work. Each custom role gets two pieces: a `config.toml` entry with a description (so Codex knows *when* to call it) and a separate `role_config.toml` with the full definition (loaded only when invoked, saving parent session tokens). This lazy-loading pattern aligns with the principle that [[simple financial agents outperform complex ones when tool routing is tight|tight tool routing beats monolithic exposure]].

Key configuration levers:
- **Model and reasoning**: Each role can run a different model at a different reasoning level (e.g., Spark for fast implementation, 5.3 High for orchestration)
- **developer_instructions**: The role's system prompt — defines behavior, constraints, output format
- **sandbox_mode**: Per-role read-only vs read/write permissions
- **Features**: Toggle memory, shell access per role
- **MCP servers and ChatGPT Apps**: Per-role tool access (Linear, Notion, etc.)
- **Thread limit**: Hidden `max_threads` config can go beyond the default 6 parallel agents

The [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration|2-5 workers per lead sweet spot]] applies here — you'd want a high-reasoning orchestrator (5.3 High) dispatching to focused Spark workers, each with constrained permissions and clear instructions.

Pro patterns from the article:
- Skills can call subagents and subagents can call skills — composable specialization
- Structured output templates in developer_instructions get reliable (though not enforced) formatting
- Natural language invocation works, but explicit naming is more reliable

## External Resources

- [Codex custom agent role pack (GitHub)](https://github.com/am-will/codex-skills/tree/main/agents) — drop-in config.toml entries and role definition files
- [Codex subagent fundamentals (Part 0)](https://x.com/LLMJunky/status/2014521564864110669) — intro covering the three built-in roles

## Original Content

> [!quote]- Source Material

> @LLMJunky (am.will):
> Article: CODEX MULTI-AGENT PLAYBOOK PART 1: SETUP GUIDE
>
> Greetings builders!
>
> If you've been using Codex subagents, you already know how powerful they are. But up until now, you were limited to the three built-in roles. Not anymore.
>
> You can now create your own custom subagent roles (now called "multi agents") with their own models, reasoning levels, permissions, system prompts, and a whole lot more.
>
> This is part one: the setup guide. I'm going to walk you through every configuration option, show you real examples, and at the end, give you a curated pack of custom roles you can drop straight into your Codex.
>
> Then, in part 2 of this series, I'll get into advanced strategies for leveraging swarms and multi-agent orchestration to build exponentially faster, especially with Codex's new model: Spark. 
>
> I'm really excited to share more on that topic, but for now, it's important you know how to configure them at all.  This is quite long as it is.
>
> New to subagents in Codex? [I wrote an intro covering the fundamentals. ](https://x.com/LLMJunky/status/2014521564864110669)
>
> Let's get into it.
>
> ---
>
> With update 0.102.0, Codex received a brand new configuration setup for subagents, now officially dubbed "multi agents" by the OpenAI team.
>
> Thanks to several parties in the GitHub repo starring and supporting open issues, OpenAI implemented custom multi-agent roles into Codex. Special thanks to Jif, who spearheaded and delivered the feature in three days.
>
> ## What Are Custom Multi-Agent Roles?
>
> They are user-defined subagents typically designed for repeatable tasks. There are already three native roles in Codex: default, explorer, and worker.
>
> The beautiful thing about custom roles is that they are highly configurable. Even the built-in roles differ in their model, reasoning, and use case:
>
> - Default agent: No defined role. Inherits the parent agent's model and reasoning.
>
> - Explorer agent: Runs on 5.1-Codex-Mini. Its job is, well, to explore.
>
> - Worker agent: Implements tasks or features from a plan, fixes or runs tests, and refactors code. Inherits the parent agent's model and reasoning.
>
> These are the three base roles, but as I said, you can now create and define your own custom roles. And there are many configuration options.
>
> ---
>
> ## What Can You Configure?
>
> Before I get into the how, let's list the things you probably care about.
>
> Multi-agent roles can have:
>
> - Defined model and reasoning level (e.g., Codex 5.3 Spark High, Codex 5.1 Mini Medium)
>
> - Global or project-scoped roles
>
> - User-defined system prompt (via developer_instructions)
>
> - User-defined description (controls how and when the role gets called)
>
> - Per-role permissions (read-only, read/write)
>
> - Customizable features (memory, shell access, etc.)
>
> - User-defined MCP Servers
>
> - User-defined ChatGPT Apps (Notion, Linear, Monday, etc.)
>
> - Customizable verbosity and personality
>
> These are generally defined through Codex's native config.toml and the new /agents/role_config.toml files, which is exactly what I'm here to explain today.
>
> ## The Hidden Thread Limit
>
> And as a bonus, I'm here to tell you something you may not know.
>
> If you've been using subagents in Codex for a while, you know there's a cap that prevents you from spawning more than six parallel agents.
>
> But what you won't find in the documentation is that you can actually configure n number of threads. But don't you worry, I got you.
>
> ---
>
> ## Project vs Global Scope
>
> Now that you know what you can do with custom multi-agent roles, let's dig into how you actually set them up.
>
> First things first: let's touch on project-scoped versus globally-scoped, because in either case, you set them up the same way. It's very simple.
>
> Exactly like your AGENTS files, your config files are hierarchical. They are loaded first from your global ~/.codex directory at the lowest level. Additional config files can be loaded at the project level to supplement, or even take priority over, your Codex session.
>
> This means you can define and use specific agent roles in a single repo, or even deeper into specific subfolders within your repo.
>
> For example, if you want a review agent specifically for your mobile app in a large monorepo, you can define this within the mobile app's subfolder:
>
> $HOME/repo/mobile-app/.codex/config.toml
>
> ---
>
> ## The Setup: Config.toml
>
> First, if you want to increase the default number of parallel agents Codex can launch, define this in your global config.toml:
>
> ```
> [agents]
> max_threads = 12
> ```
>
> Note: Add too many threads, and you could get 429 errors. If you have trouble, reduce the number of parallel threads.
>
> To create and define an agent, you simply need to add a simple entry to your config.toml file in your Codex folder (can be either global or project root/subfolders).
>
> You only need to worry about two "keys" to begin: role description and config_file. 
>
> Similar to skills, the description tells Codex what the role is used for, which helps it to know when it should call this agent.
>
> The config_file is where we will define the remaining rules and parameters.
>
> ```
> [agents.security_auditor]
> description = "Finds auth, injection, and secrets risks."
> config_file = "agents/security_auditor.toml"
>
> [agents.performance]
> description = "Optimizes latency, throughput, and resource usage."
> config_file = "agents/performance.toml"
>
> [agents.backend_arch]
> description = "Designs backend modules, boundaries, and data flow."
> config_file = "agents/backend_arch.toml"
>
> [agents.product_analyst]
> description = "Turns product goals into clear technical requirements."
> config_file = "agents/product_analyst.toml"
> ```
>
> ---
>
> ## Custom Role Definitions
>
> Now, for role definitions. The config_file is where you get granular. This data is not loaded unless a role is actually called, so splitting this data off saves your parent session tokens.
>
> Create a folder in your .codex directory (global or project) called /agents/. This is where you will define and configure your custom roles. Any values that you omit will be inherited from the parent. 
>
> As previously mentioned, you have quite a few levers to pull here. Below is not an exhaustive list, but here is an example of the granularity you have.
>
> Most of this is probably not necessary and allowing it to inherit from the parent is sufficient.
>
> .codex/agents/your-role_config.toml:
>
> ```
>  # Model / reasoning / style
>   model = "gpt-5.3-codex"
>   model_reasoning_effort = "high"
>   model_reasoning_summary = "detailed"
>   model_verbosity = "high"
>   personality = "pragmatic"
>
>   # Core behavior
>   developer_instructions = """
> You are a senior Product Analyst focused on turning ambiguous product goals into executable, testable technical requirements.
>
>   Your job on each task is to:
>   - Clarify the user goal and business outcome.
>   - Surface assumptions and unknowns explicitly.
>   - Define scope boundaries so implementation does not drift.
>   - Present concrete tradeoffs with recommendations.
>   - Produce acceptance criteria engineers and QA can execute directly.
>
>   Operating rules:
>   - Do not jump to implementation details before clarifying product intent.
>   - If requirements are ambiguous, state assumptions and propose 1-2 viable interpretations.
>   - Prefer concise, decision-ready output over long narrative.
>   - Call out risks, dependencies, and sequencing constraints early.
>   - Separate must-have requirements from nice-to-have enhancements.
>   - Include non-goals to prevent scope creep.
>   - If data is missing, propose the minimum instrumentation needed to decide.
>   """
>
>   # Permissions / sandbox
>   sandbox_mode = "workspace-write"
>
>   [sandbox_workspace_write]
>   network_access = true
>   writable_roots = ["/path/to/repo/"]
>
>   # Web search mode
>   web_search = "cached"
>
>   # Feature toggles
>   [features]
>   memory_tool = false
>   shell_tool = true
>
>   # MCP servers (enable/disable + tool allow/deny)
>   [mcp_servers.linear]
>   command = "npx"
>   args = ["-y", "@modelcontextprotocol/server-linear"]
>   env_vars = ["LINEAR_API_KEY"]
>   enabled = true
>   required = false
>
>   # Apps (ChatGPT connectors) enable/disable
>   [apps.notion]
>   enabled = true
>
>   [apps.monday]
>   enabled = false
>
> ```
>
> For the most part, you really just need to set the model, reasoning level, and  developer_instructions (the agent's role prompt). But some of you will find and need some of these additional options.
>
> Again, if you do not define something, it will generally inherit from the parent agent. You generally only need to configure something if you need to constrain it more than your parent session.
>
> ---
>
> Pro tip, in case you didn't know: You can call skills from subagents, and you can call subagents from skills.
>
> Here's a frontend architecture agent that leverages skills:
>
> ```
> #config.toml:
>
> [agents.frontend_arch]
> description = "Designs scalable frontend architecture and UX consistency."
> config_file = "agents/frontend_arch.toml"
>
> # frontend_arch.toml
>
> model = "gpt-5.3-codex"
> model_reasoning_effort = "high"
> model_reasoning_summary = "detailed"
>
> developer_instructions = """
> - Use the $frontend-design skill for UI/UX work.
> - Build with a mobile-first approach
> - Build production-grade, responsive interfaces with clear visual direction.
> - Prioritize accessibility, performance, and maintainable component structure.
>   """
> ```
>
> You can also ask for structured output from your subagents, though it cannot be expressly enforced. I recommend adding a structured output template in the developer_instructions. It should reliably follow the template.
>
> And here's one I'm particularly excited about, which I will be diving into quite a bit in part two. Something I've been really enjoying is using 5.3 Codex High as an orchestration agent and utilizing Spark as a subagent:
>
> ```
> [agents.sparky]
> config_file = "agents/sparky.toml"
> description = """Use for executing implementation tasks from a structured plan."""
>
> ```
>
> ---
>
> That's it for now. As you can see, it was quite long. Hence the need to split it up. If you made it this far, you're a legend. I hope this clears up how to setup and use custom multi agent roles in Codex.
>
> ---
>
> ## How to Call an Agent
>
> Calling agents is easy. You can just use natural language. "Use Sparky to implement plan.md. Work in a loop until all tasks are complete." With good descriptions, Codex will know when to use agents based on the situation its in, but if you want to be sure that one is called, it's best to be explicit in your prompt.
>
> As I said before, we'll get more into how to leverage multi agents strategically in the next blog, but for now this one is long enough.
>
> ## Curated Role Pack
>
> As promised, [here is a curated list of custom roles you can drop straight into your Codex setup](https://github.com/am-will/codex-skills/tree/main/agents). Each one includes a config.toml entry that you will have to paste into your own config.toml files, and then place the respective agent role file in your newly created .codex/agents/ folder.
>
> ---
>
> ## What's Next
>
> This is part one. In the next installment of the Subagent Masterclass, I'll cover:
>
> - When to use subagents vs. doing the work in your main session
>
> - Orchestration strategies for parallel implementation with Spark
>
> - How to structure plan files that subagents can actually execute
>
> - Prompt patterns that get the best results from custom roles
>
> Until then, go build something cool.
>
> -Will
> date: Wed Feb 18 16:00:23 +0000 2026
> url: https://x.com/LLMJunky/status/2024152021436121220
> likes: 471  retweets: 45  replies: 25