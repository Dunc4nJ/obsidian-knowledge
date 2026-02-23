---
created: 2026-01-31
description: Progressive disclosure pattern — 4-layer filter forcing agent selectivity over what enters context
source: community post
type: framework
---

vibe note-taking works better if you force claude code to be selective about what it reads
by default claude reads full files whenever they seem useful for the task
use 4 layers to be more selective
the pattern is called progressive disclosure
1. file tree
a session start hook injects the full file tree before claude touches anything
json
"hooks": {
    "SessionStart": [{
        "hooks": [{
            "type": "command",
            "command": "tree -L 3 -a -I '.git|.obsidian' --noreport"
        }]
    }]
}
this gives claude the map before it starts exploring
filenames are descriptive so they work as a first impression
"queries evolve during search so agents should checkpoint md"
tells you more than "search notes md"
just reading the tree already shows what notes are about
2. yaml descriptions
every note has a one sentence description in the frontmatter
yaml
---
description: Memory retrieval in brains works through spreading activation where neighbors prime each other. Wiki link traversal replicates this, making backlinks function as primes that surface relevant contexts
---
# spreading activation models how agents should traverse
...
the description elaborates the title
if something seems interesting claude queries it with ripgrep
bash
rg "^description:" 01_thinking/*.md
3. outline
if a note passes the description filter claude checks the outline
sometimes you only need one section and loading the full file would create noise
grep -n "^#" "01_thinking/knowledge-work.md"
# output:
# 5:# knowledge-work
# 13:## Core Ideas
# 19:## Tensions
# 23:## Gaps
now claude knows where to look and can read what it needs
4. full content
if everything seems relevant for the task claude loads the full file
but only for notes that passed all three filters
most notes never get here but thats the point
when claude has to justify each read it curates better
the mcp parallel
this isnt a new pattern
mcp tool discovery works the same way
when you have 50+ tools claude doesnt load all definitions into context upfront
tool specs are available but deferred until claude actually searches for them
plaintext
tool list → tool search → tool references → full definitions
same structure:
plaintext
file tree → descriptions → outline → full content
implementation
the whole thing is just:
a SessionStart hook that runs `tree`
yaml frontmatter with a description field
instructions in claude md telling claude to check descriptions before reading
just a few constraints that force selectivity

## Connections

This progressive disclosure pattern is one of the architectural pillars synthesized in [[Obsidian as Agentic Memory]] — it determines how agents navigate the vault without drowning in context. The vault itself is one of [[four memory layers serve different knowledge types]], and progressive disclosure is what makes the vault layer usable at scale. The [[OpenAI internal data agent succeeds through six layers of context not model capability alone|OpenAI data agent]] arrived at a similar layered retrieval pattern for querying 600PB of data.

---

From another user:

claude starts every session with recent context + available tools:

session start hook

calls session-context .py which collects info from files:

# Branches (git)
- task/add-feature - 2026-01-25
- ...

# Files (ls)
 - [[plan - add auth]] - 2026-01-25
 - ...

# Skills (all with tldr front matter)
- /done - End session with export and merge offer
- /reflect - Extract learnings from file

# Agents (all with tldr)
- code-reviewer - Reviews code...

(files have tldr: <description> in the yaml front matter)
