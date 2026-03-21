---
created: 2026-03-21
description: Marco Franzon argues that agent skills are self-contained folders with scripts, assets, and data — not static markdown — making skill creation the modern equivalent of developer environment setup.
source: https://x.com/mfranz_on/status/2034032446249791542
type: learning
---

## Key Takeaways

Franzon's central thesis is that skills are executable capability packages, not documentation. A skill folder contains a core `SKILL.md` plus supporting scripts, sample data, configuration, templates, and helper utilities — the agent navigates the folder, discovers pieces, and runs scripts in real time. This aligns directly with how [[repo-local skills and AGENTS.md turn recurring engineering work into repeatable agent workflows]] describes the Agent Skills specification's progressive-disclosure model, where `SKILL.md` frontmatter loads at startup but the full folder structure activates only on demand.

The "skills are the new software" framing reframes developer setup. Instead of just installing tools and configuring stacks, elite developers now build custom skill folders — refactoring skills with analysis scripts, domain modeling skills with templates and validation, AI orchestration skills with prompt chains and evaluation metrics. Each skill ships like a product feature with its own update cycle. This resonates with [[the best agent skills fit one category and grow from gotchas not upfront design]], where the best skills emerge from real-world friction rather than theoretical design.

The article also highlights that [[agent skills should self-improve through observed failures not stay as static prompt files]] — Franzon explicitly argues that skills need regular updates (new scripts, refined instructions, fresh examples, versioning) to stay relevant, just like software. Static skills rot the same way static documentation does, which connects to [[static agent skills rot silently because the codebase model and task distribution change around them]].

The democratization angle is worth noting: anyone can create a skill folder with a clear `SKILL.md` and supporting files, making advanced capability accessible without elite credentials. Skills function like open-source packages — learnable, improvable, shareable. This echoes [[skill-creator now brings software testing rigor to agent skill authoring without requiring code]], which lowers the bar for skill creation through structured authoring tools.

## External Resources

- [@trq212's article on skill folder structure](https://x.com/trq212) — Referenced by Franzon as the source of the "skills are folders, not just markdown files" insight
- [Agent Skills specification](https://agentskills.io/specification) — The specification defining `SKILL.md` frontmatter and progressive-disclosure skill loading

## Original Content

> @mfranz_on — 2026-03-17
>
> Article: Skills Are Not Just Markdown Files
>
> I use coding agents every day and skills are essential. They are like vim plugins in my opinion. Using a coding agent without skills is like using vanilla vim. Crazy right?
>
> I like this quote from a recent article by @trq212:
>
> > A common misconception we hear about skills is that they are "just markdown files", but the most interesting part of skills is that they're not just text files. They're folders that can include scripts, assets, data, etc. that the agent can discover, explore and manipulate.
>
> This richer structure is what makes skills powerful in the age of AI agents and modern development. And it reveals a deeper truth: in today's world, skills are the new software.
>
> ## Beyond Static Text: Skills as Living Folders
>
> For years, we treated expertise like static documentation a résumé, a certification, or a simple prompt. In the emerging world of AI agents and skill-first systems, that model is evolving rapidly.
>
> A true skill is no longer a flat markdown instruction set. It's a self-contained package: a folder with a core description (often SKILL.md), plus supporting scripts, sample data, configuration files, helper utilities, and even small executables or templates. The agent doesn't just read it, it navigates the folder, discovers relevant pieces, runs scripts when needed, and adapts in real time.
>
> This is far more than documentation. It's executable capability.
>
> Just as modern software isn't a single source file but an entire project directory with dependencies, build scripts, tests, and assets, human (and agent) skills are now structured the same way: rich, discoverable, and actionable.
>
> ## The Shift from Static Knowledge to Dynamic Skills
>
> Education and careers were once built around static knowledge degrees, fixed certifications, and rote memorization. Today, that's insufficient.
>
> Technologies change faster than curricula can adapt. What was cutting-edge yesterday is table stakes tomorrow. Skills, however, are different. When designed as rich folders rather than plain text, they become:
>
> - Discoverable: Agents or teammates can explore the contents and find exactly what they need.
>
> - Executable: Scripts and tools inside the skill can run automatically.
>
> - Extensible: You can add new assets, update data, or include new examples without rewriting everything.
>
> - Transferable: The same skill folder can be shared across projects, teams, or even different AI agents.
>
> For developers, this shift is especially transformative. Your personal skill library becomes your most valuable repository a living collection of folders that encode not just "how to do something," but the full context, tools, and logic required to do it exceptionally well.
>
> ## Skills as the Operating System of Developers and Agents
>
> If organizations (and AI systems) are like computers, then skills are their true operating system.
>
> In developer workflows and agentic setups, hiring and capability evaluation now focus less on credentials and more on what someone (or some agent) can actually do. Companies map skills like system architects map modules. AI agents scan skill folders at startup, build a registry, and invoke the right capabilities on demand.
>
> For a developer, skills are the most important instrument in your toolkit. Your IDE, language, or framework is just the runtime environment. The real power lies in the custom skills you've built those rich folders that let you (and your agents) solve problems faster, more consistently, and more creatively than off-the-shelf tools allow.
>
> ## Creating New & Custom Skills Is the New Developer Setup
>
> The old way of "setting up" as a developer was installing tools: picking an editor, configuring a stack, and learning popular frameworks.
>
> Today's elite developers go further. Creating new and custom skills is the new developer setup.
>
> Instead of relying solely on existing libraries or generic AI prompts, top developers build their own skill folders:
>
> - A "refactoring" skill with scripts that analyze code smells, suggest patterns, and apply transformations automatically.
>
> - A "domain modeling" skill containing templates, example diagrams, validation scripts, and data sets specific to their industry.
>
> - An "AI orchestration" skill with prompt chains, example outputs, evaluation metrics, and helper functions for reliable agent behavior.
>
> - Custom automation skills that include executable scripts, configuration files, and test cases — turning repetitive tasks into reusable, discoverable capabilities.
>
> These aren't just notes in a markdown file. They're complete, self-contained packages that an agent can explore and manipulate. The result? Developers are no longer limited by what the ecosystem provides. They extend it.
>
> When you treat skill creation as core development work, your "setup" becomes infinitely more powerful. You ship new versions of your own capabilities the same way you ship product features.
>
> ## The Skill Folder Update Cycle
>
> Software needs regular updates to stay secure and relevant. Skills do too.
>
> The best developers and agent systems maintain an active "skill update cycle":
>
> - Adding new scripts or assets as technologies evolve
>
> - Refining instructions based on real-world outcomes
>
> - Including fresh examples and data
>
> - Testing and versioning the entire folder
>
> Online platforms, open-source skill repositories, and collaborative communities make this easier than ever. Those who treat their skills like evolving software repositories continuously refactoring, expanding, and sharing them stay ahead in a world where change is constant.
>
> ## Skills Drive Innovation for Humans and Agents
>
> Innovation doesn't come from tools or base models alone. It comes from skilled application.
>
> A powerful AI agent without rich skills is like a computer with no installed programs full of potential but idle. Give it well-structured skill folders (with scripts, data, and logic), and it becomes a specialist that can discover, reason, and act effectively.
>
> The same holds for human developers. A generic framework is just potential. A custom skill folder turns that potential into breakthroughs: novel architectures, internal tools that 10x productivity, or creative solutions that generic approaches miss.
>
> Organizations and developers who invest in building rich, folder-based skill libraries don't just keep pace with technology they define what's possible.
>
> ## The Democratization of Advanced Capabilities
>
> One of the most exciting aspects of this folder-based skill model is its accessibility.
>
> Anyone with a computer and curiosity can create sophisticated skills. You don't need elite credentials. You build a folder, add a clear SKILL.md, include supporting files, and suddenly you (or your agent) have a new, reusable capability.
>
> Skills function like open-source software packages: learn them, improve them, share the entire folder, and watch communities expand them. This lowers barriers and creates meritocratic opportunities based on what you can actually build and demonstrate.
>
> ## Building a Skill-First Future
>
> To thrive, adopt a skill-first mindset:
>
> - For individuals and developers: Stop asking only "What tools should I learn?" Ask "What rich skills (folders) do I want to master and create?" Treat every project as a chance to build or upgrade a skill package.
>
> - For teams and organizations: Encourage skill sharing via folder-based repositories. Evaluate and reward the creation of custom, executable skills.
>
> - For AI systems: Design agents that treat skills as explorable directories rather than flat prompts.
>
> Educational institutions should evolve too teaching not just theory, but the practice of packaging knowledge into discoverable, manipulable skill structures.
>
> Technology gives us the raw infrastructure, but skills  especially rich, folder-based skills shape how we use it.
>
> For developers, skills are the ultimate instrument. Creating new and custom ones is the new setup  the way we extend our capabilities and push the boundaries of what's possible.
>
> In a world of accelerating change, the most valuable asset isn't a specific tool, title, or model. It's the ability to build, update, and deploy rich skills.
>
> Because ultimately, skills are the true software of the modern world and the best ones aren't flat text. They're dynamic, executable folders that keep evolving.
>
> Engagement: 85 likes | 5 retweets | 4 replies
> [Original post](https://x.com/mfranz_on/status/2034032446249791542)
