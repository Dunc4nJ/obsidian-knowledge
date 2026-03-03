---
created: 2026-02-05
description: Skills work best as modular, folder-based workflows that combine deterministic scripts and LLM steps via progressive disclosure, enabling reliable multi-skill automation pipelines.
source: https://x.com/llmjunky/status/2019439161560695197
type: framework
---

# skill workflows

## Core claim
Skills are most useful when treated as **folder-based workflow modules** (scripts + templates + nested skills), not as "just prompts/markdown," because this structure makes complex LLM automations repeatable and token-efficient via progressive disclosure.

## Key takeaways

- **A skill is a folder (a mini product), not a single markdown file.** The SKILL.md is more like a README/docstring: it describes what's inside and when to run which pieces; the real value lives in the scripts, templates, and sub-skills.

- **Combine determinism and LLM flexibility deliberately.** Put exact steps (API calls, file ops, formatting) into scripts, and use the LLM for synthesis/writing/creative decisions. This echoes the "use the right substrate for the job" pattern in [[capturing internal APIs can replace most agent browser automation]].

- **Progressive disclosure improves token efficiency and reliability.** The agent should load only what it needs, step-by-step, instead of dumping an entire repo/skill into context. This aligns with [[progressive disclosure filters force agent selectivity over what enters context]] and the broader separation of memory layers described in [[four memory layers serve different knowledge types]].

- **Nested composition is the scaling trick.** Skills can call subagents, which can call other skills; treated like functions with clear inputs/outputs, you can compose 10+ skills into one repeatable pipeline. This connects to orchestration ideas in [[multi-agent squads work when independent sessions share a mission control system]].

- **Templates are the quality control layer.** Templates inside skill folders make outputs consistent across runs and across subagents (e.g., consistent article format, consistent email HTML structure).

## Original Content

> [!quote]- Source Material
> 
> @LLMJunky (am.will):
> Article: You're Wrong About Skills
> 
> I often see a take so bad that I can't help but facepalm. Experienced devs turning their noses up at skills as though they are some kind of novelty toy made up by frontier labs to sell subscriptions.
> 
> > "I don't need any of that. I've been coding for 15 years."
> 
> > "I don't use skills. I just write good prompts."
> 
> > "They're just markdown files."
> 
> They brag that they can do it all without them. And fair enough. But that doesn't mean you shouldn't.
> 
> This is very short-sighted. And it's holding people back from what is, in my opinion, a perfect framework to get the most out of an LLM.
> 
> ## Let Me Set the Record Straight
> 
> Skills are not markdown files. Skills are folders.
> 
> And inside those folders you can host a variety of subfolders, scripts, templates, and even sub-skills. The SKILL.md is just the README for the agent. It outlines how the agent should explore the folder, what to use, and when.
> 
> Calling a skill "just a markdown file" is like calling a repo "just a README." SKILL.md tells you how to use what's inside. The folder is the actual product.
> 
> And, as a bonus note: to make this even more impactful, your coding agent will ONLY load into context what it actually needs, one step at a time, so its HIGHLY token efficient.
> 
> ## Why This Matters
> 
> With this approach, you can build powerful, repeatable automations. You can use scripts where pure determinism shines, and LLMs where non-determinism shines.
> 
> Think about that for a second. You're not choosing between rigid automation and flexible AI. You're combining both in a single orchestrated system. The SKILL.md tells your agent when and where to use the contents of the folder in a step-by-step nature, with progressive disclosure. It only sees what it needs, when it needs it.
> 
> This is how you get the most out of an LLM.
> 
> ## A Real-World Example
> 
> Let me walk you through a workflow I built that runs my entire newsletter pipeline. This is not theoretical. I use this regularly, and it works the same way every single time.
> 
> I have a skill where I give it three URLs for news stories I want to cover in a financial newsletter.
> 
> Step 1: Price Data
> 
> The skill is called. First thing it does is run a script to call an API and pull seven days of price data. This is deterministic. No LLM needed. Just a script living inside the skill folder doing exactly what it's told.
> 
> Step 2: Article Generation
> 
> The skill then launches three subagents, one per URL. Each subagent calls another skill inside it: a blog writing skill. This second-order skill scrapes the story, then each subagent performs three adjacent web searches to gather additional context. The article is written using a template that lives inside the second-order skill folder.
> 
> Step 3: Image Generation
> 
> Articles are written. Then they call yet another skill, which calls another deterministic script to generate blog cover images. Everything is saved to its own folder.
> 
> Step 4: WordPress Publishing
> 
> Another skill is called that automatically posts everything to WordPress. Each subagent returns a summary of the article, along with the filepaths to the article and cover images, back up to the parent agent.
> 
> Step 5: Newsletter Assembly
> 
> Back at the parent level, the newsletter agent crafts a newsletter using the three articles the subagents returned. The newsletter is written with a very specific template living inside the skill folder. It summarizes the articles and invites readers to visit WordPress to read more, which was already posted automatically via the earlier steps.
> 
> Step 6: Email Output
> 
> Finally, the newsletter is written to a file and generates an email formatted in HTML according to the template, ready for review and sending.
> 
> ## The Anatomy of This Workflow
> 
> Let's zoom out and look at what just happened:
> 
> - 10 skills working together
> 
> - 3 subagents running in parallel
> 
> - 9 scripts handling deterministic tasks
> 
> - 4 templates ensuring consistent output
> 
> - One command to kick it all off
> 
> All of these folders are compartmentalized and called in a deterministic fashion. They are modular, yet work in unison. The subagents call more skills, which have their own instructions and templates, which call more skills, and so on.
> 
> This workflow is highly complex. And it is 100% repeatable. Reliable. Every single run produces the same caliber of output because the system is laid out step by step in the SKILL.md, told where the templates are, and told when to call subagents, which also call other skills, which have instructions to call other skills, and so forth.
> 
> ## The Architecture That Makes It Work
> 
> The key concept is nesting. A skill can call a subagent. That subagent can call another skill. That skill has its own readme, its own templates, its own scripts. Each layer is self-contained but designed to plug into the layer above it.
> 
> Think of it like functions in code. Each skill is a function with clear inputs and outputs. The SKILL.md is the docstring. The folder contents are the implementation. And just like functions, you can compose them into larger systems.
> 
> Scripts handle the work that needs to be exact: API calls, file operations, data formatting. LLMs handle the work that benefits from flexibility: writing, research, synthesis, creative decisions. The skill folder is where these two worlds meet.
> 
> ## You Can Get Very Sophisticated With This
> 
> The newsletter example is just one pattern. The same architecture applies to any repeatable workflow. Content pipelines, code generation, data analysis, report building, client deliverables. Anything you find yourself doing more than once can be packaged into a skill and run the same way every time.
> 
> The devs who understand this are building systems. The devs who dismiss skills as "just markdown files" are still doing the work by hand. And that's fine, good for you. But you're not special for it either.
> 
> ## See It in Action
> 
> Don't take my word for it. Watch the full newsletter pipeline run end to end in the video below. From URLs to published WordPress articles to an inbox-ready HTML email.  A total of 10 skills, 3 subagents, 9 scripts, 4 templates called. Fully automated. Fully repeatable.
> 
> Welcome to the club. I've automated huge chunks of my job. You can too.
> date: Thu Feb 05 15:53:10 +0000 2026
> url: https://x.com/LLMJunky/status/2019439161560695197
> ──────────────────────────────────────────────────
> 
> @jcochranio (Jason Cochran):
> @LLMJunky Oof that IS a REALLY bad take. Wow.
> date: Thu Feb 05 16:00:03 +0000 2026
> url: https://x.com/jcochranio/status/2019440896572301423
> ──────────────────────────────────────────────────
> 
> @LLMJunky (am.will):
> @jcochranio I see it all the time. I just picked one at random. 0 shade to this guy at all. It's just a lack of understanding imo.
> date: Thu Feb 05 16:01:20 +0000 2026
> url: https://x.com/LLMJunky/status/2019441219596599729
> ──────────────────────────────────────────────────
> 
> @E__Strobel (E__Strobel):
> So many, even people who ought to know better, have such a limited view of what can be done.
> 
> When Opal first came out, I created a few flows which turned ‘most of the day’ activities into a button push. But I still had to copy/paste the results, run a script, then copy/paste back into another Opal flow.
> 
> Yesterday, I screenshot those flows, including the prompts at each step. Then I had CoWork build a skill from it. Now the only manual step is to do a pass through the final output for polish.
> 
> So now, any repeatable process you can draw a diagram of and clearly define each step of, can now be easily turned into a skill without any special knowledge.
> 
> Skills are ‘macros’ all grown up.
> date: Thu Feb 05 16:18:21 +0000 2026
> url: https://x.com/E__Strobel/status/2019445500718542935
> ──────────────────────────────────────────────────
> 
> @LLMJunky (am.will):
> @E__Strobel That's badass! Nice work, yes you can automate a great deal using this very simple strategy you described. Solid!
> date: Thu Feb 05 16:40:03 +0000 2026
> url: https://x.com/LLMJunky/status/2019450959894655168
> ──────────────────────────────────────────────────
> 
> @inancgumus (inanc):
> @LLMJunky Skills are overly hyped until LLMs are trained to use them effectively without us having to install hooks.
> date: Thu Feb 05 19:23:19 +0000 2026
> url: https://x.com/inancgumus/status/2019492049209151526
> ──────────────────────────────────────────────────
> 
> @LLMJunky (am.will):
> @inancgumus if anything, they're underhyped. if you can't see the value in them, then you're probably not using them to their fullest ability. 
> 
> they also dont need hooks. codex has no hooks. models are good at tool calling just through the cli.
> date: Thu Feb 05 19:25:00 +0000 2026
> url: https://x.com/LLMJunky/status/2019492473622372696
> ──────────────────────────────────────────────────
> 
> @BoostSparken (Vicare icaros):
> @LLMJunky This really clicked for me when you framed skills as architecture, not prompts.
> date: Fri Feb 06 02:00:05 +0000 2026
> url: https://x.com/BoostSparken/status/2019591900257481144
> ──────────────────────────────────────────────────
> 
> @LLMJunky (am.will):
> @BoostSparken Cool! Glad I could help. Yeah they're literally just a file tree with a readme. Like their own little repositories
> date: Fri Feb 06 02:05:32 +0000 2026
> url: https://x.com/LLMJunky/status/2019593271018942977
> ──────────────────────────────────────────────────
> 
> @GogHeng (Noctrix):
> @LLMJunky I found your content very enlightening. May I ask, did you initially have the Agent read a workflow of skills first, and then have the Agent follow the workflow to call and deliver each step one by one?
> date: Fri Feb 06 08:46:58 +0000 2026
> url: https://x.com/GogHeng/status/2019694294223983039
> ──────────────────────────────────────────────────
> 
> @zby (Zbigniew Lukasiak):
> Actually the difference of READMES and SKILLS is their activation rule. READMEs are directory activated - you start working in a directory you read the README from that directory. SKILLS activation is different - it the SKILLS description index is always in the background.
> 
> https://t.co/VUKkbexyVC
> date: Fri Feb 06 11:58:49 +0000 2026
> url: https://x.com/zby/status/2019742573980537335
> ──────────────────────────────────────────────────
> 
> @LLMJunky (am.will):
> @zby its just an analogy :)
> date: Fri Feb 06 18:12:53 +0000 2026
> url: https://x.com/LLMJunky/status/2019836711833071734
> ──────────────────────────────────────────────────
> 
> @_overment (Adam):
> @LLMJunky and there’s one more thing: agents can create and update skills, meaning they can learn from their mistakes or adjust either based on a feedback or some generalized rules.
> date: Sat Feb 07 01:13:18 +0000 2026
> url: https://x.com/_overment/status/2019942512274915483
> ──────────────────────────────────────────────────
