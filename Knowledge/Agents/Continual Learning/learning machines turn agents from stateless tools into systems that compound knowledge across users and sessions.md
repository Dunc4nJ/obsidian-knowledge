---
created: 2026-02-25
description: Agents that learn — not just remember — across users and sessions via extensible Learning Stores. Cross-user knowledge continuity lets one person's insight benefit the whole team automatically.
source: https://x.com/ashpreetbedi/status/2010781132418064750
type: framework
---

# Learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions

The wrong question is "what should the agent remember?" — the right question is "what should the agent learn?" Memory is static (a database of facts about the user). Learning is dynamic (it evolves, compounds, gets sharper, and has purpose). The breakthrough: when one engineer teaches an agent something, a different engineer in a different session benefits automatically. No shared context, no explicit handoff — the knowledge compounds. This extends the memory architecture principles in [[four memory layers serve different knowledge types]] into active learning territory.

## Key Takeaways

Cross-user, cross-session knowledge continuity is the key unlock. In the prototype, one engineer mentioned cutting egress costs. Later, a different engineer in a separate session asked about Datadog vs Grafana — the agent unprompted flagged Datadog's egress costs as something the team was trying to reduce. One person's context became everyone's context without any explicit handoff. If agents are the future, this continuity is a must.

The formula: Agent = LLM + Tools + Instructions. Learning Machine = Agent + Learning Stores. Learning stores run in the background capturing different types of knowledge from interactions. The default stores handle generic knowledge, but the real power is custom stores for domain-specific learning — where source code lives, how to run tests, which environment to use, what the gotchas are.

The protocol is intentionally extensible with three methods: `recall` (what has the agent learned?), `process` (extract learnings from conversations), and `build_context` (inject learnings into the agent's context). The bet isn't that the right stores were built, but that the right protocol was built for developers who understand their domain — legal, medical, finance, ops — to build theirs.

The roadmap: Phase 1 is learning stores (shipped). Phase 2 adds decision logging — agents that learn from what happened. Phase 3 is self-improvement — agents that propose updates to their own instructions. This progression from passive memory to active learning to self-modification connects to the [[PARA and atomic facts give AI agents durable structured memory]] architecture but pushes beyond it into active knowledge synthesis.

Skills and MCP don't solve the continuity problem. Memory doesn't either — remembering that a user lives in New York doesn't teach the agent how they build, test, debug, and think through problems. The massive-prompt-collection workaround for project context is tedious and doesn't scale.

## External Resources

- [Learning Machines cookbooks (Agno)](https://agno.link/learning) — implementation examples
- [Agno multi-agent runtime](https://agno.link/gh) — open-source framework

## Original Content

> [!quote]- Source Material
> 
> @ashpreetbedi (Ashpreet Bedi):
> Article: From Agents to Learning Machines
> 
> Agents are changing how we work. For most people this is still a prediction, but for me it's reality.
> 
> I do spec-first development: claude-code (and my homegrown gcode) writes the specs, then writes 100% of the code. Agents keep specs and code in sync, and use the same apps I use. I haven't touched Linear in weeks.
> 
> But something's been bugging me: new sessions don't have continuity. I have to provide the same context over and over. My workaround is a massive collection of prompts for each project but that's getting tedious to maintain.
> 
> Skills, MCP - I've tried it all. Memory doesn't fix it either. The agent can remember that I live in New York. But that doesn't teach it how I build? How I test, debug and think through problems?
> 
> ## Check this out
> 
> I've been testing a prototype with my team for a few days, here's a sample session:
> 
> Session 1 — an engineer tells the agent:
> 
> > "We're trying to cut down on egress costs. Any ideas?"
> 
> The agent saves that the team is working on cutting egress costs.
> 
> Session 2 — a different engineer, different conversation, asks:
> 
> > "I'm deciding between datadog and grafana. Any recommendations?"
> 
> The agent lets the second engineer know about datadog's egress costs, mentioning it's something the team is trying to reduce. Unprompted.
> 
> One person taught the agent something. Another person on the team benefited from it. No shared context. No explicit handoff. The agent just... knew.
> 
> If you're on a team of people working with agents all day, you know how crazy this is. When one person figures out how to test a tricky feature or shares an insight, everyone benefits automatically. The knowledge compounds.
> 
> > If Agents are the future then cross-user, cross-session knowledge continuity is a must.
> 
> # We've been asking the wrong question
> 
> I kept trying to solve the memory problem. Better extraction. Smarter retrieval. More context. It felt like tightening a screw with a hammer.
> 
> Then it clicked.
> 
> I was asking "what should the agent remember?" and instead should have asked "what should the agent learn?"
> 
> Memory is a noun. Learning is a verb.
> 
> This might seem like wordplay but the change in perspective yields a fundamental shift. Memory is static: a database of facts about the user. Learning is dynamic: it evolves, compounds, gets sharper and has a purpose.
> 
> Agents can now learn! Every interaction makes them sharper.
> 
> # Learning Machines
> 
> - Agent = LLM + Tools + Instructions
> 
> - Learning Machine = Agent + Learning Stores
> 
> Learning stores run in the background and capture different types of knowledge, picking stuff up that can be helpful in future runs.
> 
> But here's the breakthrough: they're extensible by design. You can build custom stores for your domain, workflow and weird specific way of doing things.
> 
> For me, when I'm coding, I want my agent to learn where the source code for a feature lives. Where the testing cookbooks are. How to run the tests. Which environment to use. When the agent learns how to test my feature, everyone on the team should benefit from it.
> 
> # How It Works
> 
> Here's how you turn an agent into a Learning Machine:
> 
> ```python
> from agno.agent import Agent
> from agno.db.postgres import PostgresDb
> from agno.learn import LearningMachine, LearnedKnowledgeConfig, LearningMode
> 
> agent = Agent(
>     model=OpenAIResponses(id="gpt-5.2"),
>     db=PostgresDb(db_url="..."),
>     learning=LearningMachine(
>         user_memory=True,
>         learned_knowledge=LearnedKnowledgeConfig(
>             mode=LearningMode.AGENTIC,  # agent decides when to save/search
>         ),
>     ),
> )
> ```
> 
> That's it. Your agent can capture insights, patterns and know-how from your interactions, it has tools to save learnings and search them later.
> 
> # The protocol
> 
> The default stores handle generic knowledge. But what if I need my agent to learn project-specific stuff: where the source code lives, how to run tests, which environment to use.
> 
> Solution: Built your own Learning Store:
> 
> ```python
> from agno.learn import LearningStore
> 
> class ProjectContext(LearningStore):
>     """Learns the structure and workflow of a specific project."""
> 
>     def recall(self, project_id: str, **kwargs):
>         # What has the agent learned about this project?
>         ...
> 
>     def process(self, messages: List[Message], **kwargs):
>         # Extract learnings from every conversation:
>         # - Where does the source code live?
>         # - How do we run tests?
>         # - Which environment to use?
>         # - What are the gotchas?
>         ...
> 
>     def build_context(self, data) -> str:
>         # Inject learnings into the agent's context
>         return f"<project_context>\n{data}\n</project_context>"
> 
> # Plug it in
> learning = LearningMachine(
>     custom_stores={
>         "project": ProjectContextStore(
>             context={
>                 "project_id": "learning-machine",
>             },
>         ),
>     },
> )
> ```
> 
> Three methods and we have a domain-specific learning store.
> 
> Now every nudge I give the agent gets extracted and available next run. This is what I use with my homegrown `gcode` agent.
> 
> The default stores get you started. Custom stores teach your agent anything.
> 
> # Where this goes
> 
> This is Phase 1. It works. Let's see how far we can push this.
> 
> Phase 2 adds decision logging - agents that learn from what happened.
> 
> Phase 3 is the weird one: self-improvement. Agents that propose updates to their own instructions.
> 
> I don't know if all of this works yet. We're building to find out.
> 
> Here's what I do know: the most valuable learning stores don't exist yet. And they won't come from us. They'll come from developers who understand their domain - legal, medical, finance, ops - stuff we'll never know as well as they do.
> 
> My bet's not that we built the right stores, but that we built the right protocol for others to build theirs.
> 
> If you're interested, checkout the [cookbooks](https://agno.link/learning) on Github.
> 
> Build something. Break something. Tell me what's missing.
> 
> ---
> 
> Learning Machines is part of [Agno](https://agno.link/gh), the multi-agent runtime.
> date: Mon Jan 12 18:29:15 +0000 2026
> url: https://x.com/ashpreetbedi/status/2010781132418064750
