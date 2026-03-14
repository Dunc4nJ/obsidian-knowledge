---
created: 2026-03-14
description: Augment Code's analysis of context waste in agent sessions, showing that copied AGENTS.md and CLAUDE.md files reduce task success rates while increasing cost, with research backing a minimal failure-driven approach.
source: https://www.augmentcode.com/blog/your-agents-context-is-a-junk-drawer
type: synthesis
---

## Key Takeaways

The article's central statistic — a 556:1 ratio of copiers to contributors on a popular agent rules repo — crystallizes the problem with how developers approach agent configuration. People download context packs like npm packages without auditing them, creating what one developer called "confetti in the root directory." This mirrors the pattern we've seen in [[context engineering is what separates toy agents from production systems|context engineering]] discussions: the scaffolding around the model matters enormously, but most people cargo-cult it instead of engineering it.

The ETH Zurich paper finding that context files *reduce* task success rates compared to no context — while increasing inference cost by 20% — is a direct challenge to the "more instructions = better output" assumption. Even human-written files only improved performance by ~4%, and on Sonnet 4.5 performance actually *dropped*. This connects to [[Factory treats context as a scarce resource that must be budgeted and curated across layered scaffolding|Factory's approach of treating context as scarce budget]]: every line competes for attention, and most people are spending that budget on things the agent can already see in the codebase.

Multiple research papers converge on the same conclusion from different angles: CodeIF-Bench found additional repo context degraded instruction-following; PACIFIC showed sequential instruction chains cause increasing failures; ConInstruct found models silently resolve conflicting constraints rather than flagging them. This degradation pattern aligns with what [[how top ai companies handle context engineering|the major AI companies]] are independently discovering — the core challenge is context curation, not context volume.

The practical fix the article advocates is a pruning rubric borrowed from Jan-Niklas Wortmann: "Failure-backed? Tool-enforceable? Decision-encoding? Triggerable? If it fails all four, delete it." Vercel's eval results reinforce this — they compressed 40KB of docs into an 8KB index-style AGENTS.md and hit 100% pass rate. The article draws an explicit parallel to Rails' "convention over configuration," arguing that modern agents can derive patterns from code just as Rails derived mappings from naming conventions. This is directly relevant to how we structure our own [[agent harness is the real product|agent harness]] — the goal is minimal, failure-driven instructions rather than comprehensive documentation.

The trust gap is a useful framing: Stack Overflow's survey shows 84% of developers use AI tools but only 29% trust them (down from 40%). Distrust drives over-specification, which ironically makes the agent perform worse. The article's Tim Sylvester quote — comparing the cycle of ignored instructions and empty apologies to a dysfunctional relationship — captures why developers keep adding rules instead of pruning them.

## External Resources

- [ETH Zurich AGENTS.md evaluation paper](https://arxiv.org/abs/2602.11988) — found context files reduce task success rates vs. no context, +20% inference cost
- [CodeIF-Bench](https://arxiv.org/abs/2503.22688) — instruction-following benchmark for interactive code generation; additional repo context degrades compliance
- [ConInstruct](https://arxiv.org/abs/2511.14342) — AAAI 2026 paper on detecting conflicting constraints; models silently pick one interpretation
- [PACIFIC](https://arxiv.org/abs/2512.10713) — sequential instruction following degrades as chain length increases
- [Anthropic context engineering docs](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — warns bloated CLAUDE.md causes instruction ignoring
- [Vercel agents-md evals](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) — 8KB compressed index AGENTS.md achieved 100% pass rate vs skills approach
- [Jan-Niklas Wortmann on agent instructions](https://www.wordman.dev/blog/agent-instructions) — pruning rubric: failure-backed, tool-enforceable, decision-encoding, triggerable
- [Birgitta Böckeler on context engineering](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html) — Martin Fowler site piece on context overhead
- [Stack Overflow 2025 AI trust survey](https://stackoverflow.blog/2026/02/18/closing-the-developer-ai-trust-gap/) — 84% use AI tools, only 29% trust them

## Original Content

> [!quote]- Source Material
> There's a GitHub repo for sharing AI coding agent rules. It has 37,800 stars. It has 68 contributors.
> That's a 556-to-1 ratio. For every person who contributed a rule, 556 people copied one without reading it.
> This is the state of AI agent configuration in 2026. Developers downloading context packs like npm packages, stacking markdown files they didn't write, wondering why their agent keeps ignoring instructions.
> Open a typical project that's been through a few months of AI-assisted development. You'll find some combination of CLAUDE.md, .cursorrules, copilot-instructions.md, AGENTS.md, and maybe a gemini.md for good measure. Almost the same content in each one. Slowly drifting apart. Technically required by a different tool.
> One developer described it as "confetti in the root directory." Another resorted to symlinks to keep five config files in sync. A third built a CLI tool with 156 validation rules across 28 categories because AI config files now need their own linter.
>
> *Illustration: the configuration proliferation problem*
> ![[augmentcode-junkdrawer-001.png]]
>
> The pattern is familiar if you've been around long enough. Someone publishes a "starter template," thousands of people copy it, nobody audits it, and six months later everyone's debugging configuration instead of shipping code. We did this with webpack. We did this with Docker Compose.
> The difference this time: a bad webpack config made your build slow. A bad agent config makes your agent dumber.
> In February 2026, researchers at ETH Zurich published [a paper evaluating AGENTS.md files](https://arxiv.org/abs/2602.11988) across multiple coding agents and LLMs. The finding was blunt.
> Context files reduce task success rates compared to providing no repository context, while increasing inference cost by over 20%.Adding context files made agents perform worse than giving them nothing. And it cost more.
> The paper's author [clarified on Hacker News](https://news.ycombinator.com/item?id=43176795) that even human-written context files only improved performance by about 4%, and that improvement wasn't consistent across models. On Sonnet 4.5, performance actually dropped by over 2%.
> [CodeIF-Bench](https://arxiv.org/abs/2503.22688) tested instruction-following in interactive code generation across multi-turn sessions. One of their key findings: "additional repository context" actively degraded models' ability to follow instructions. More context, worse compliance. The researchers identified context management as the critical unsolved problem.
> [ConInstruct](https://arxiv.org/abs/2511.14342) (AAAI 2026) went further. They tested whether models can even detect conflicting constraints in their instructions. Claude 4.5 Sonnet scored 87.3% F1 at detecting conflicts. Not bad. But here's the problem: even when models spotted the contradiction, they almost never flagged it to the user. They just silently picked one interpretation and kept going. Your config file says "use tabs" in one section and "use spaces" in another. The model notices. It doesn't tell you. It just picks.
>
> *Illustration: the research evidence*
> ![[augmentcode-junkdrawer-002.png]]
>
> [PACIFIC](https://arxiv.org/abs/2512.10713) confirmed the sequential version of the same problem. As instruction chains get longer in code tasks, even state-of-the-art models lose track. The framework generates benchmarks of increasing difficulty, and the results are consistent: more sequential instructions, more failures. Even among advanced models.
> Your AGENTS.md has how many instructions?Anthropic knows this. [Their own docs](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) warn: "Bloated CLAUDE.md files cause Claude to ignore your actual instructions." [Karpathy](https://x.com/karpathy/status/1937902205765607626) said it plainly: "Too much or too irrelevant and the LLM costs might go up and performance might come down."
> [Birgitta Böckeler](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html), writing on Martin Fowler's site: "An agent's effectiveness goes down when it gets too much context, and too much context is a cost factor as well."
> More rules, worse output.
> Because we don't trust the agent.
> [Stack Overflow's 2025 survey](https://stackoverflow.blog/2026/02/18/closing-the-developer-ai-trust-gap/): 84% of developers use or plan to use AI tools. Only 29% trust them. Down from 40%.
> When you don't trust something, you over-specify. You write a 200-line AGENTS.md explaining your folder structure because you don't believe the agent can figure it out. You add coding style rules your linter already enforces. You paste in architecture docs the agent could read from the repo itself.
> Two years ago, this made sense. Early agents were genuinely blind. They couldn't see your codebase. You had to explain everything.
> That muscle memory stuck. But agents got better. Context engines got better. The tools now read your code, your dependencies, your git history, your file structure. They derive patterns automatically. Developers are still writing instructions for the blind version.
> Tim Sylvester nailed the frustration cycle: "You write down these extensive lists of rules. The agent dutifully ignores them. You call it out. 'You're right to call me out!' it chirps, and apologizes. These are empty apologies it performs by rote. Many of us have been in relationships like this before."
> That last line lands because it's true. The instinct when something ignores you is to repeat yourself louder. More rules. More detail. More emphasis. It doesn't work with people and it doesn't work with agents.
> The research says that's exactly backwards.
>
> *Illustration: the trust and over-specification cycle*
> ![[augmentcode-junkdrawer-003.png]]
>
> The fix is knowing which context goes where.
> What the agent can already see. Your code, your file structure, your dependencies, your git history. A good context engine reads all of this. You don't need to restate it in a markdown file. That's like writing a README for a coworker who already has the repo cloned.
> What the agent can't see. How to deploy. How to run tests. Team conventions that live in people's heads, not in linter configs. What your staging environment looks like. Why you made that weird architecture decision three months ago.
> Most people use the second category's tools for the first category's problems. They write AGENTS.md files describing their code structure. They add rules explaining API patterns that are already visible in the code. The agent knows. You're adding noise.
> A good context engine reads your codebase so you don't have to explain it. The less you tell the agent about what it can already see, the more attention budget remains for the things it genuinely can't figure out.
>
> [Vercel ran evals](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) on Next.js 16 APIs comparing two approaches: skills (on-demand retrieval) and AGENTS.md (passive context). Skills produced zero improvement over baseline. The agent had access to the docs but never bothered to look at them.
> Then they tried something dumber. They compressed their entire docs index into an 8KB AGENTS.md file. Not the full documentation. Just an index pointing to retrievable files. 100% pass rate across build, lint, and test.
> 40KB compressed to 8KB. Perfect score. The "dumb" approach won.
> [Jan-Niklas Wortmann](https://www.wordman.dev/blog/agent-instructions) went through a similar arc. Started with 80+ lines of aspirational rules. Cut to 30 lines of failure-backed instructions. "Dramatically better behavior." The pruning rubric he landed on: "Failure-backed? Tool-enforceable? Decision-encoding? Triggerable? If it fails all four, delete it."
> Start with nothing. Add what prevents failures. Verify it actually helps.
> Open your AGENTS.md or CLAUDE.md right now. For each line, ask: would the agent make a mistake without this?
> If no, delete it.
> Things that almost certainly don't belong:
> Your folder structure. The agent can see it. Your tech stack. It's in package.json or Cargo.toml or go.mod. Coding style rules your linter already enforces. ("Never send an LLM to do a linter's job.") API patterns visible in your existing code. Generic best practices like "write clean code" or "follow SOLID principles." The agent was trained on the internet. It knows.
> What should stay: build, test, and lint commands. Deploy steps. Environment setup. Team conventions that live in people's heads. Known gotchas. Architecture decisions that aren't obvious from reading the code.
> [DHH](https://x.com/dhh/status/2018574874675929544) made the connection explicit: "Convention over configuration set the path for 20+ years of great training data for AI to use today." If your codebase follows conventions, the agent already understands them. You don't need to re-explain Rails to an agent trained on every Rails app on GitHub.
>
> *Illustration: convention over configuration for agents*
> ![[augmentcode-junkdrawer-004.png]]
>
> The best agent setup isn't the one with the most files. It's the one where every line prevents a specific failure.Your agent's system prompt already contains dozens of instructions. Every benchmark from the last year tells the same story: instruction-following degrades as constraint density increases. CodeIF-Bench showed it in interactive coding. PACIFIC showed it in sequential code tasks. ConInstruct showed models silently ignore conflicts rather than ask. That leaves a narrow window for your AGENTS.md, your skills, your plugins, and your actual prompts. Combined.
> Every line you add pushes something else out. A rule about folder structure displaces a rule about deploy steps. A generic best practice crowds out a project-specific gotcha. You're choosing what gets ignored.
> Treat every line like ad space. It has to justify its rent.
> The Rails community solved a version of this twenty years ago. Before Rails, you configured everything. Database mappings. URL routing. File locations. All explicit, all manual. Rails said: follow the convention and skip the config. The framework figures it out.
> Agents are getting there. The tools derive context from your codebase now. Most developers haven't updated their habits to match.
> Open your AGENTS.md right now. For every line, ask: does this prevent a failure the agent would actually make?
> If you can't point to the failure, delete the line.
> You'll notice the difference when it actually follows the ones that remain.
>
> [Original article](https://www.augmentcode.com/blog/your-agents-context-is-a-junk-drawer)
