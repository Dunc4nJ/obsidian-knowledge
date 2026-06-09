---
created: 2026-06-09
description: Printing Press is a generator plus catalog that turns any API, website, or community fan project into a token-efficient Go CLI, a Claude Code skill, an OpenClaw skill, and an MCP server from a single prompt — and a library skill lets agents discover and install pre-printed ones.
source: https://printingpress.dev/
type: framework
---

## Key Takeaways

- Printing Press collapses the four artifacts an agent actually wants — a Go binary, a Claude Code skill, an OpenClaw skill, and an MCP server — into the output of one `/printing-press` prompt, biasing toward the [[CLIs are the agent-native interface because legacy tooling is already machine-readable|agent-native CLI surface]] over raw HTTP for every API or fan-project source it accepts.
- The press explicitly bakes in Peter Steinberger's `discrawl` / `gogcli` playbook: a local SQLite mirror beats remote API calls, compound commands beat ten round trips, and an agent-native CLI beats raw HTTP — meaning every printed binary aims for sub-100ms compound queries instead of N HTTPS hops, and the Linear example (`SELECT ... FROM issues JOIN issue_relations ...`) answers in 50ms a question Linear's API can't answer at all.
- "Every API has a secret identity" is the editorial thesis: the press doesn't transcribe the docs, it reshapes the surface around what the source is actually useful for (Discord as a searchable knowledge base, Linear as a team behavior observatory), so each CLI exposes high-leverage compound commands instead of mirroring the underlying REST shape.
- Sources don't need a public API — the press happily targets websites and community fan projects, which generalizes the [[capturing internal APIs can replace most agent browser automation|"unbrowse" pattern]] into a first-class generator path; one prompt yields the same four artifacts whether the input is an OpenAPI spec, a scraped site, or a community SDK.
- The companion `printing-press-library` ships as both an npx CLI (`search`, `install`, `list`, `update`, `uninstall`) and as an installable skill for [[Symphony turns Linear tickets into merged PRs by orchestrating parallel Codex agents with hot-reloadable prompts|orchestrator-style agents]] under OpenClaw (`clawhub install printing-press-library`) and Hermes (`hermes skills install mvanhorn/printing-press-library/skills/printing-press-library`), so the agent itself can browse the catalog (~200+ CLIs across 19 categories at launch) and decide what muscle memory to add.
- Category coverage at launch skews heavily commercial-utility: Media and Entertainment (31), Productivity (29), Developer Tools (23), Commerce (22), Marketing (21), Travel (18) — i.e. the press is being aimed at end-user agent personal-assistant work (flights, recipes, NBA tickets, filmography) rather than just developer infra, which is consistent with the "muscle memory for agents" framing.

## External Resources

- [Printing Press](https://printingpress.dev/) — the landing page itself; entry point for both the library (catalog) and the generator (press).
- [@mvanhorn/printing-press-library](https://www.npmjs.com/package/@mvanhorn/printing-press-library) — npx-installable catalog CLI with `search`, `install`, `list`, `update`, `uninstall`.
- [github.com/mvanhorn/cli-printing-press](https://github.com/mvanhorn/cli-printing-press) — the generator binary (`go install .../v4/cmd/cli-printing-press@latest`); requires Go 1.26.3+, Claude Code, and Node.
- [Vercel open-agent-skills CLI (`skills`)](https://www.npmjs.com/package/skills) — `npx skills add mvanhorn/cli-printing-press/skills ...` installs the press skills into Claude Code.
- [OpenClaw](https://github.com/openclaw/openclaw) — referenced as a target skill format (`clawhub install printing-press-library`); same project mentioned in [[capturing internal APIs can replace most agent browser automation]] as the host for `unbrowse`.
- [Hermes](https://github.com/) — second target skill format (`hermes skills install ...`); referenced as a peer to OpenClaw for agent skill installation.
- [Library categories](https://printingpress.dev/library/) — 19 vertical catalogs at launch: `accounting`, `ai`, `auth`, `cloud`, `commerce`, `developer-tools`, `devices`, `education`, `food-and-dining`, `marketing`, `media-and-entertainment`, `monitoring`, `other`, `payments`, `productivity`, `project-management`, `sales-and-crm`, `social-and-messaging`, `travel`.
- Peter Steinberger's `discrawl` and `gogcli` — credited inspiration for the "local SQLite mirror + compound commands + agent-native CLI" playbook the press codifies.

## Original Content

*Hero / brand card from printingpress.dev (the printing-press metaphor itself).*
![[printingpress-og-card.png]]

> [!quote]- Source Material
>
> **Title:** Printing Press
> **Source:** https://printingpress.dev/
> **Description (from page metadata):** From an API spec, a website with no public API, or a community fan project - one command prints a Go CLI, a Claude Code skill, an OpenClaw skill, and an MCP server. Muscle memory for agents.
>
> NOW PRINTING·PL. A
>
> # Welcome to the Printing Press. Print an agent-native CLI for any API, app, or site — from a single prompt. Or install one the community already made.
>
> From an API spec, from a website with no public API, from a beloved community fan project - one prompt prints a token-efficient Go CLI, a Claude Code skill, an OpenClaw skill, and an MCP server. Peter Steinberger showed the way with discrawl and gogcli: a local SQLite mirror beats a remote API call, compound commands beat ten round trips, and an agent-native CLI beats raw HTTP. The press bakes that playbook into every binary it prints. Muscle memory for agents.
>
> ---
>
> ## Every API has a secret identity.
>
> Discord isn't just a chat app - it's a searchable knowledge base. Linear isn't just an issue tracker - it's a team behavior observatory. The Printing Press finds that secret and builds the CLI around it.
>
> ---
>
> Get started
>
> ### Discover and install CLIs
>
> Search the catalog, then install any CLI plus its agent skill — one or several at once.
>
> * `npx -y @mvanhorn/printing-press-library search travel`
>   Find tools by keyword or category. `list` shows the whole catalog.
> * `npx -y @mvanhorn/printing-press-library install flight-goat booking-com`
>   Install by name — one or several. Pulls the Go binary and the agent skill together. Requires Node.
> * `npx -y @mvanhorn/printing-press-library --help`
>   See every command — `list` for the whole catalog, `list --category travel` to filter, plus `update` and `uninstall`.
>
> **Let your agent pick — OpenClaw & Hermes**
>
> Install the Printing Press Library skill so your agent can search and discover the catalog on its own:
>
> * OpenClaw
>   `clawhub install printing-press-library`
> * Hermes
>   `hermes skills install mvanhorn/printing-press-library/skills/printing-press-library`
>
> Then paste this to your agent:
>
> > You have a Printing Press Library skill installed that gives you access to agent-native CLIs and companion skills. Using everything you know about me and how I work, recommend which CLIs I should install — and install the ones I approve.
>
> ---
>
> ### Build your own
>
> Run the press to print a token-efficient CLI, agent skill, and MCP server for any API, website, or community project.
>
> * `go install github.com/mvanhorn/cli-printing-press/v4/cmd/cli-printing-press@latest`
>   Install the generator binary. Requires Go 1.26.3+, Claude Code, and Node.
> * `npx skills add mvanhorn/cli-printing-press/skills --skill '*' -g -a claude-code -y`
>   Install the press skills into Claude Code (Vercel's open-agent-skills CLI).
> * `claude`
>   Start Claude Code from any folder.
> * `/printing-press <app or website>`
>   Inside Claude Code — print a CLI for an API by name, or point it at a website. No spec needed.
>
> ---
>
> ### Non-stop flights over 8 hours from SEA, Dec 24 to Jan 1, cheapest first.
>
> `$ /pp-flight-goat sea long-haul nonstop dec 24 to jan 1, 4 pax, cheapest first`
>
> Nonstop 8+ hour SEA round-trips, Dec 24 2026 to Jan 1 2027, 4 passengers, cheapest first.
>
> | #  | Destination      | Total  | Per pax | Airline         | Outbound |
> | -- | ---------------- | ------ | ------- | --------------- | -------- |
> | 1  | London LHR       | $4,953 | $1,238  | Delta DL20      | 9h42m    |
> | 2  | Amsterdam AMS    | $5,052 | $1,263  | Delta DL142     | 9h50m    |
> | 3  | Tokyo Haneda HND | $5,817 | $1,454  | ANA NH117       | 10h35m   |
> | 4  | Paris CDG        | $6,515 | $1,629  | Air France AF77 | 9h35m    |
> | 5  | Frankfurt FRA    | $6,538 | $1,635  | Lufthansa LH491 | 10h10m   |
> | 6  | Doha DOH         | $6,912 | $1,728  | Qatar QR720     | 14h35m   |
> | 7  | Dubai DXB        | $7,142 | $1,786  | Emirates EK230  | 14h35m   |
> | 8  | Seoul ICN        | $7,634 | $1,909  | Delta DL197     | 11h55m   |
> | 9  | Taipei TPE       | $8,296 | $2,074  | EVA BR25        | 13h10m   |
> | 10 | Istanbul IST     | $8,725 | $2,181  | Turkish TK204   | 12h      |
>
> ---
>
> ### When does OKC play next, and what's the cheapest fly-in / next-morning-out?
>
> `$ /pp-espn nba okc round 2 game 1 + /pp-flight-goat sea-okc, fly-in same day`
>
> The setup
>
> OKC just won Game 4 vs Phoenix, 131-122. Round 2 Game 1 is TBD on date and opponent. Best estimate for the next OKC home game: Sat May 9 or Sun May 10.
>
> | Date                    | Out (for ~7pm CT)                      | RT total |
> | ----------------------- | -------------------------------------- | -------- |
> | Fri May 8 → Sat May 9   | WN 3936/735 6:30am → 4:40pm CT         | $437     |
> | Sat May 9 → Sun May 10  | F9 1176/1928 6:52pm → arrives too late | skip     |
> | Sun May 10 → Mon May 11 | WN 3936/3537 6:15am → 3:05pm CT        | $437     |
>
> Pick: Wait 24-48h for ESPN to publish Round 2 Game 1, then book Southwest 1-stop for $437 RT (Wanna Get Away+ for refundable flexibility). Skip Frontier May 9 outbound; lands after tip.
>
> ---
>
> ### Kelly Van Horn's filmography, sorted by Rotten Tomatoes.
>
> `$ /pp-movie-goat person 'Kelly Van Horn' --sort rotten-tomatoes`
>
> Kelly Van Horn filmography sorted by Rotten Tomatoes - one CLI call, two source APIs (TMDb + OMDb).
>
> | RT  | Title (Year)                     | Role                             |
> | --- | -------------------------------- | -------------------------------- |
> | 91% | Raising Arizona (1987)           | First Assistant Director         |
> | 69% | Independence Day (1996)          | Unit Production Manager          |
> | 50% | Forget Paris (1995)              | Production Manager / Co-Producer |
> | 49% | Eight Legged Freaks (2002)       | UPM / Co-Producer                |
> | 45% | The Day After Tomorrow (2004)    | Executive Producer               |
> | 38% | Almost an Angel (1990)           | Line Producer                    |
> | 29% | The Thirteenth Floor (1999)      | UPM / Co-Producer                |
> | 24% | Resident Evil: Extinction (2007) | Executive Producer               |
> | 22% | Leave It to Beaver (1997)        | Co-Producer                      |
> | 20% | Godzilla (1998)                  | UPM / Co-Producer                |
> | 20% | Out on a Limb (1992)             | UPM / Line Producer              |
>
> ---
>
> ### Find me the best chocolate cake.
>
> `$ /pp-recipe-goat find chocolate cake --rank trust --servings 8`
>
> Servings - 8+
>
> 1. Sift 2 cups all-purpose flour, 3/4 cup cocoa, and a pinch of salt together.
> 2. Beat 2 cups sugar with 1/2 cup neutral oil; add 2 large eggs one at a time.
> 3. Bake at 350F for 30 min timer
>
> Widget has scalable servings, ingredient links inside the steps, and timers - all from a single recipe-goat call.
>
> ---
>
> ### Every blocked issue whose blocker has been stuck for a week.
>
> `$ /pp-linear sql 'blocked issues whose blocker hasn't moved in 7 days'`
>
> ```
> linear-pp-cli sql --compact <<SQL
> SELECT i.identifier, i.title, age(now(), b.updated_at) AS stuck
> FROM issues i JOIN issue_relations r ON r.issue_id = i.id
> JOIN issues b ON b.id = r.related_issue_id
> WHERE r.type = 'blocked_by' AND b.state = 'in_progress'
> AND b.updated_at < now() - interval '7 days';
> SQL
> ```
>
> * ENG-412 Crash on cold-start · blocked 11d
> * ENG-388 Reconnect dropped sockets · blocked 9d
> * ENG-301 Backfill missing rows · blocked 8d
>
> 50ms against the local SQLite mirror. Compound queries the Linear API can't answer.
>
> ---
>
> ### Find a verified email for a person you've never met.
>
> `$ /pp-contact-goat 'Jane Doe' company:Acme --use deepline`
>
> 1. Look up on LinkedIn
> 2. Cross-check Happenstance for warm intros
> 3. Pay Deepline for the verified email
>
> Magic-moment recording in flight. The CLI ships today; the type-specimen page lands when the screen recording does.
>
> ---
>
> ### Search the library
>
> Search
>
> * [Accounting — 2 CLIs: qbo · xero — Browse →](https://printingpress.dev/library/accounting)
> * [AI — 9 CLIs: elevenlabs · midjourney · ollama-cloud · +6 more — Browse →](https://printingpress.dev/library/ai)
> * [Auth — 1 CLI: 1password — Browse →](https://printingpress.dev/library/auth)
> * [Cloud — 6 CLIs: azure-functions-admin · cf-domain · cloud-run-admin · +3 more — Browse →](https://printingpress.dev/library/cloud)
> * [Commerce — 22 CLIs: amazon-ads · amazon-orders · amazon-seller · +19 more — Browse →](https://printingpress.dev/library/commerce)
> * [Developer Tools — 23 CLIs: agent-capture · airframe · apify · +20 more — Browse →](https://printingpress.dev/library/developer-tools)
> * [Devices — 7 CLIs: adminbyrequest · dreo · hayward-omnilogic · +4 more — Browse →](https://printingpress.dev/library/devices)
> * [Education — 2 CLIs: ankiweb · lawhub — Browse →](https://printingpress.dev/library/education)
> * [Food and Dining — 12 CLIs: allrecipes · anylist · coffee-goat · +9 more — Browse →](https://printingpress.dev/library/food-and-dining)
> * [Marketing — 21 CLIs: ahrefs · beehiiv · bento · +18 more — Browse →](https://printingpress.dev/library/marketing)
> * [Media and Entertainment — 31 CLIs: archive-is · art-goat · bandsintown · +28 more — Browse →](https://printingpress.dev/library/media-and-entertainment)
> * [Monitoring — 2 CLIs: adguard-home · sentry — Browse →](https://printingpress.dev/library/monitoring)
> * [Other — 20 CLIs: american-reindustrialization · apartments · ars-sicilia · +17 more — Browse →](https://printingpress.dev/library/other)
> * [Payments — 12 CLIs: coingecko · exchangerate-api · kalshi · +9 more — Browse →](https://printingpress.dev/library/payments)
> * [Productivity — 29 CLIs: breezedoc · cal-com · chrome-history · +26 more — Browse →](https://printingpress.dev/library/productivity)
> * [Project Management — 4 CLIs: clickup · jira · linear · +1 more — Browse →](https://printingpress.dev/library/project-management)
> * [Sales and CRM — 11 CLIs: conduyt-crm · contact-goat · eu-tenders · +8 more — Browse →](https://printingpress.dev/library/sales-and-crm)
> * [Social and Messaging — 5 CLIs: bird · multimail · pushover · +2 more — Browse →](https://printingpress.dev/library/social-and-messaging)
> * [Travel — 18 CLIs: airbnb · alaska-airlines · alltrails · +15 more — Browse →](https://printingpress.dev/library/travel)
>
> ---
>
> ♪ Listen to the official Printing Press song · Neon Sardine Orchestra — Printing Press ♪ ▶
>
> [Original page](https://printingpress.dev/)

*Cover art for the official "Printing Press" song by Neon Sardine Orchestra (linked from the page footer).*
![[printingpress-neon-sardine-cover.png]]
