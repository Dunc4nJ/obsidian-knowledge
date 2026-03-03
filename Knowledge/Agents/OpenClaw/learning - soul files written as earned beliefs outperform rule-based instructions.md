---
created: 2026-02-20
type: learning
description: Converting SOUL.md directives from rules to belief-narrative makes LLMs internalize values rather than comply with checklists
source: session-digest
---
# Soul files written as earned beliefs outperform rule-based instructions

When writing agent SOUL.md files, there are two styles:

**Rules (weaker):**
> "Think before acting. Pause. Consider. Then execute with confidence."

**Beliefs (stronger):**
> "I've learned that rushing creates more work than it saves. Early on I'd jump straight to execution — ship the first answer, fix it later. But rework costs more than the pause ever did."

Same values, but the belief framing reads as *earned wisdom* rather than a *checklist to comply with*. The model treats internalized beliefs differently from external directives — it's the difference between "I was told not to rush" and "I know from experience that rushing backfires."

**Companion pattern — anti-pattern capture:**
Add a living anti-pattern section to AGENTS.md where agents log specific failures as they happen ("I don't [X] because [what went wrong]"). Periodically distill mature anti-patterns into the soul. You can't invent anti-patterns from nothing; they come from real failures.

Related: [[background agents shift alerting from reactive keyword matching to proactive semantic discovery]]
