---
created: 2026-02-23
description: Anthropic demonstrates that wrapping MCP servers as TypeScript files on a filesystem lets agents load tool definitions on demand and filter results in code, reducing context overhead from 150K tokens to 2K — a 98.7% reduction.
source: https://www.anthropic.com/engineering/code-execution-with-mcp
type: framework
---

## Key Takeaways

The core problem is that standard MCP clients load all tool definitions upfront into context. With hundreds of tools across dozens of servers, this means processing 150,000+ tokens before the agent even reads the user's request. The fix is generating a filesystem tree where each MCP tool becomes a TypeScript file with typed interfaces. The agent discovers tools by listing directories and reading only what it needs — the same [[progressive disclosure filters force agent selectivity over what enters context|progressive disclosure]] pattern that works for agent memory, now applied to tool discovery.

Intermediate results are the second token drain. In a standard tool-calling loop, every result passes through the model context. A two-hour meeting transcript gets loaded into context from Google Drive, then the model writes it back out to push it into Salesforce — doubling the token cost for a pure data-transfer operation. With code execution, the transcript flows through the execution environment as a variable: `const transcript = await gdrive.getDocument(...)` then `await salesforce.updateRecord({data: {Notes: transcript}})`. The model never sees the content. This directly addresses the [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|context tax]] problem at the architectural level rather than through optimization tweaks.

The privacy benefit is underappreciated. When data flows through code execution rather than the model context, intermediate results stay in the sandbox by default. The MCP client can also tokenize PII automatically — replacing emails with `[EMAIL_1]` before the model sees them, then untokenizing on the way back out to the destination tool. This makes privacy a property of the architecture, not a prompt instruction.

State persistence through filesystem access enables agents to save intermediate results and resume work across executions. More interestingly, agents can save their own working code as reusable functions — essentially building [[skill workflows|skills]] from experience. The article explicitly connects this to Claude's Skills concept: adding a SKILL.md to saved functions creates a structured skill the agent can reference later. This is the same pattern as [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand|skill graphs]] but emerging organically from the agent's own work rather than being pre-authored.

Control flow in code is dramatically more efficient than chaining tool calls through the model. A polling loop that checks Slack every 5 seconds for a deployment notification becomes a simple `while` loop in TypeScript instead of repeated model invocations. Each iteration that would normally require a full model round-trip (time to first token, reasoning, tool call generation) becomes a millisecond-level code execution. This compounds: complex workflows with conditionals, loops, and error handling that might take 20+ model turns collapse into a single code block.

Cloudflare independently reached the same conclusion, calling this pattern "Code Mode." The convergence suggests this is becoming the standard architecture for production MCP deployments — code execution as the default, direct tool calling as the fallback for simple single-tool operations.

The tradeoff is real: code execution requires a secure sandbox with resource limits and monitoring. The article explicitly notes this operational overhead should be weighed against the token savings. For agents that only use a few tools, direct calling is simpler. The break-even point is somewhere around the complexity where intermediate results start flowing between tools.

## External Resources

- [Model Context Protocol](https://modelcontextprotocol.io/) — open standard for connecting AI agents to external systems
- [MCP Community](https://modelcontextprotocol.io/community/communication) — community hub for sharing MCP implementations
- [MCP SDKs](https://modelcontextprotocol.io/docs/sdk) — official SDKs for all major programming languages
- [Claude Code Sandboxing](https://www.anthropic.com/engineering/claude-code-sandboxing) — Anthropic's approach to secure code execution environments
- [Claude Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) — reusable instruction/script/resource folders for specialized agent tasks
- [Cloudflare Code Mode](https://blog.cloudflare.com/code-mode/) — Cloudflare's independent findings on code execution with MCP

## Original Content

*How the MCP client orchestrates tool calls and results through the model context window*
![[anthropic-mcp-code-001.png]]

> [!quote]- Source Material
> **Code execution with MCP: building more efficient AI agents** — Anthropic Engineering, by Adam Jones and Conor Kelly
>
> The Model Context Protocol (MCP) is an open standard for connecting AI agents to external systems. Connecting agents to tools and data traditionally requires a custom integration for each pairing, creating fragmentation and duplicated effort that makes it difficult to scale truly connected systems. MCP provides a universal protocol—developers implement MCP once in their agent and it unlocks an entire ecosystem of integrations.
>
> Since launching MCP in November 2024, adoption has been rapid: the community has built thousands of MCP servers, SDKs are available for all major programming languages, and the industry has adopted MCP as the de-facto standard for connecting agents to tools and data.
>
> Today developers routinely build agents with access to hundreds or thousands of tools across dozens of MCP servers. However, as the number of connected tools grows, loading all tool definitions upfront and passing intermediate results through the context window slows down agents and increases costs.
>
> **Excessive token consumption from tools makes agents less efficient**
>
> As MCP usage scales, there are two common patterns that can increase agent cost and latency:
>
> 1. Tool definitions overload the context window
> 2. Intermediate tool results consume additional tokens
>
> **1. Tool definitions overload the context window**
>
> Most MCP clients load all tool definitions upfront directly into context, exposing them to the model using a direct tool-calling syntax. These tool definitions might look like:
>
> ```
> gdrive.getDocument
>      Description: Retrieves a document from Google Drive
>      Parameters:
>                 documentId (required, string): The ID of the document to retrieve
>                 fields (optional, string): Specific fields to return
>      Returns: Document object with title, body content, metadata, permissions, etc.
> ```
>
> ```
> salesforce.updateRecord
>     Description: Updates a record in Salesforce
>     Parameters:
>                objectType (required, string): Type of Salesforce object (Lead, Contact, Account, etc.)
>                recordId (required, string): The ID of the record to update
>                data (required, object): Fields to update with their new values
>      Returns: Updated record object with confirmation
> ```
>
> Tool descriptions occupy more context window space, increasing response time and costs. In cases where agents are connected to thousands of tools, they'll need to process hundreds of thousands of tokens before reading a request.
>
> **2. Intermediate tool results consume additional tokens**
>
> Most MCP clients allow models to directly call MCP tools. For example, you might ask your agent: "Download my meeting transcript from Google Drive and attach it to the Salesforce lead."
>
> The model will make calls like:
>
> ```
> TOOL CALL: gdrive.getDocument(documentId: "abc123")
>         → returns "Discussed Q4 goals...\n[full transcript text]"
>            (loaded into model context)
>
> TOOL CALL: salesforce.updateRecord(
>             objectType: "SalesMeeting",
>             recordId: "00Q5f000001abcXYZ",
>             data: { "Notes": "Discussed Q4 goals...\n[full transcript text written out]" }
>         )
>         (model needs to write entire transcript into context again)
> ```
>
> Every intermediate result must pass through the model. In this example, the full call transcript flows through twice. For a 2-hour sales meeting, that could mean processing an additional 50,000 tokens. Even larger documents may exceed context window limits, breaking the workflow.
>
> With large documents or complex data structures, models may be more likely to make mistakes when copying data between tool calls.
>
> **Code execution with MCP improves context efficiency**
>
> With code execution environments becoming more common for agents, a solution is to present MCP servers as code APIs rather than direct tool calls. The agent can then write code to interact with MCP servers. This approach addresses both challenges: agents can load only the tools they need and process data in the execution environment before passing results back to the model.
>
> One approach is to generate a file tree of all available tools from connected MCP servers:
>
> ```
> servers
> ├── google-drive
> │   ├── getDocument.ts
> │   ├── ... (other tools)
> │   └── index.ts
> ├── salesforce
> │   ├── updateRecord.ts
> │   ├── ... (other tools)
> │   └── index.ts
> └── ... (other servers)
> ```
>
> Then each tool corresponds to a file:
>
> ```typescript
> // ./servers/google-drive/getDocument.ts
> import { callMCPTool } from "../../../client.js";
>
> interface GetDocumentInput {
>   documentId: string;
> }
>
> interface GetDocumentResponse {
>   content: string;
> }
>
> /* Read a document from Google Drive */
> export async function getDocument(input: GetDocumentInput): Promise<GetDocumentResponse> {
>   return callMCPTool<GetDocumentResponse>('google_drive__get_document', input);
> }
> ```
>
> The Google Drive to Salesforce example becomes:
>
> ```typescript
> // Read transcript from Google Docs and add to Salesforce prospect
> import * as gdrive from './servers/google-drive';
> import * as salesforce from './servers/salesforce';
>
> const transcript = (await gdrive.getDocument({ documentId: 'abc123' })).content;
> await salesforce.updateRecord({
>   objectType: 'SalesMeeting',
>   recordId: '00Q5f000001abcXYZ',
>   data: { Notes: transcript }
> });
> ```
>
> The agent discovers tools by exploring the filesystem: listing the `./servers/` directory to find available servers, then reading the specific tool files it needs to understand each tool's interface. This reduces the token usage from 150,000 tokens to 2,000 tokens—a 98.7% saving.
>
> Cloudflare published similar findings, referring to code execution with MCP as "Code Mode." The core insight is the same: LLMs are adept at writing code and developers should take advantage of this strength to build agents that interact with MCP servers more efficiently.
>
> **Benefits of code execution with MCP**
>
> **Progressive disclosure**
>
> Models are great at navigating filesystems. Presenting tools as code on a filesystem allows models to read tool definitions on-demand, rather than reading them all up-front.
>
> Alternatively, a `search_tools` tool can be added to the server to find relevant definitions. Including a detail level parameter that allows the agent to select the level of detail required (name only, name and description, or full definition with schemas) helps the agent conserve context and find tools efficiently.
>
> **Context efficient tool results**
>
> When working with large datasets, agents can filter and transform results in code before returning them:
>
> ```typescript
> // Without code execution - all rows flow through context
> TOOL CALL: gdrive.getSheet(sheetId: 'abc123')
>         → returns 10,000 rows in context to filter manually
>
> // With code execution - filter in the execution environment
> const allRows = await gdrive.getSheet({ sheetId: 'abc123' });
> const pendingOrders = allRows.filter(row =>
>   row["Status"] === 'pending'
> );
> console.log(`Found ${pendingOrders.length} pending orders`);
> console.log(pendingOrders.slice(0, 5)); // Only log first 5 for review
> ```
>
> The agent sees five rows instead of 10,000. Similar patterns work for aggregations, joins across multiple data sources, or extracting specific fields.
>
> **More powerful and context-efficient control flow**
>
> Loops, conditionals, and error handling can be done with familiar code patterns rather than chaining individual tool calls:
>
> ```typescript
> let found = false;
> while (!found) {
>   const messages = await slack.getChannelHistory({ channel: 'C123456' });
>   found = messages.some(m => m.text.includes('deployment complete'));
>   if (!found) await new Promise(r => setTimeout(r, 5000));
> }
> console.log('Deployment notification received');
> ```
>
> This is more efficient than alternating between MCP tool calls and sleep commands through the agent loop. Being able to write out a conditional tree that gets executed also saves on "time to first token" latency.
>
> **Privacy-preserving operations**
>
> When agents use code execution with MCP, intermediate results stay in the execution environment by default. The agent only sees what you explicitly log or return.
>
> For sensitive workloads, the agent harness can tokenize sensitive data automatically:
>
> ```typescript
> const sheet = await gdrive.getSheet({ sheetId: 'abc123' });
> for (const row of sheet.rows) {
>   await salesforce.updateRecord({
>     objectType: 'Lead',
>     recordId: row.salesforceId,
>     data: {
>       Email: row.email,
>       Phone: row.phone,
>       Name: row.name
>     }
>   });
> }
> console.log(`Updated ${sheet.rows.length} leads`);
> ```
>
> The MCP client intercepts and tokenizes PII before it reaches the model:
>
> ```json
> [
>   { "salesforceId": "00Q...", "email": "[EMAIL_1]", "phone": "[PHONE_1]", "name": "[NAME_1]" },
>   { "salesforceId": "00Q...", "email": "[EMAIL_2]", "phone": "[PHONE_2]", "name": "[NAME_2]" }
> ]
> ```
>
> When the data is shared in another MCP tool call, it is untokenized via a lookup in the MCP client. The real data flows from Google Sheets to Salesforce, but never through the model.
>
> **State persistence and skills**
>
> Code execution with filesystem access allows agents to maintain state across operations:
>
> ```typescript
> const leads = await salesforce.query({
>   query: 'SELECT Id, Email FROM Lead LIMIT 1000'
> });
> const csvData = leads.map(l => `${l.Id},${l.Email}`).join('\n');
> await fs.writeFile('./workspace/leads.csv', csvData);
>
> // Later execution picks up where it left off
> const saved = await fs.readFile('./workspace/leads.csv', 'utf-8');
> ```
>
> Agents can also persist their own code as reusable functions:
>
> ```typescript
> // In ./skills/save-sheet-as-csv.ts
> import * as gdrive from './servers/google-drive';
> export async function saveSheetAsCsv(sheetId: string) {
>   const data = await gdrive.getSheet({ sheetId });
>   const csv = data.map(row => row.join(',')).join('\n');
>   await fs.writeFile(`./workspace/sheet-${sheetId}.csv`, csv);
>   return `./workspace/sheet-${sheetId}.csv`;
> }
>
> // Later, in any agent execution:
> import { saveSheetAsCsv } from './skills/save-sheet-as-csv';
> const csvPath = await saveSheetAsCsv('abc123');
> ```
>
> This ties in closely to the concept of Skills, folders of reusable instructions, scripts, and resources for models to improve performance on specialized tasks. Adding a SKILL.md file to these saved functions creates a structured skill that models can reference and use. Over time, this allows your agent to build a toolbox of higher-level capabilities, evolving the scaffolding that it needs to work most effectively.
>
> Note that code execution introduces its own complexity. Running agent-generated code requires a secure execution environment with appropriate sandboxing, resource limits, and monitoring. These infrastructure requirements add operational overhead and security considerations that direct tool calls avoid. The benefits of code execution—reduced token costs, lower latency, and improved tool composition—should be weighed against these implementation costs.
>
> **Summary**
>
> MCP provides a foundational protocol for agents to connect to many tools and systems. However, once too many servers are connected, tool definitions and results can consume excessive tokens, reducing agent efficiency. Although many of the problems here feel novel—context management, tool composition, state persistence—they have known solutions from software engineering. Code execution applies these established patterns to agents, letting them use familiar programming constructs to interact with MCP servers more efficiently.
>
> *Acknowledgments: This article was written by Adam Jones and Conor Kelly. Thanks to Jeremy Fox, Jerome Swannack, Stuart Ritchie, Molly Vorwerck, Matt Samuels, and Maggie Vo for feedback on drafts of this post.*
>
> [Original article](https://www.anthropic.com/engineering/code-execution-with-mcp)
