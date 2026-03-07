---
created: 2026-03-06
description: OpenAI's tool_search API feature lets models dynamically discover and load deferred tool definitions at runtime instead of preloading them all, with both hosted (server-side) and client-executed modes, preserving KV cache by injecting tools at the end of context.
source: https://developers.openai.com/api/docs/guides/tools-tool-search
type: reference
---

# OpenAI tool search dynamically loads deferred tools into context preserving cache while cutting token cost and latency

## Key Takeaways

OpenAI's `tool_search` is the Responses API equivalent of what [[tool search lets Claude Code lazy-load MCP tools when definitions exceed 10 percent of context|Claude Code implemented for MCP tools]] — lazy-loading tool definitions instead of stuffing them all into context upfront. The mechanism has two activation requirements: add `tool_search` as a tool type, and mark individual functions, namespaces, or MCP servers with `defer_loading: true`. At request start, the model only sees names and descriptions of deferred items, not their full parameter schemas.

The design offers two modes. **Hosted tool search** is fully server-side — OpenAI's API searches the deferred tools you declared and returns loaded subsets in the same response, emitting `tool_search_call` and `tool_search_output` items before the actual function call. **Client-executed tool search** gives your application control over discovery — the model emits a `tool_search_call` with structured arguments, your app performs lookup, and returns a `tool_search_output` with the matching tools. This is powerful for cases where available tools depend on tenant state, project context, or external registries.

A key architectural detail: loaded tools are injected at the **end of the context window**, which preserves the model's KV cache from prior turns. This is the same principle behind [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|the filesystem-as-tool-registry pattern]] — progressive disclosure of tool definitions to avoid upfront context bloat. OpenAI recommends grouping deferred functions into namespaces of fewer than 10 functions each, with clear high-level descriptions so the model can search effectively.

The client-executed mode also supports **advanced injection patterns** where your application returns tools that were not present in the original request at all. This opens the door to fully dynamic tool registries where the tool inventory is determined at runtime based on the conversation. Security note: OpenAI explicitly warns to validate returned schemas carefully and only expose trusted tool definitions.

## External Resources

- [OpenAI Function Calling guide](https://developers.openai.com/api/docs/guides/function-calling) — prerequisite for defining functions, namespaces, and parameter schemas
- [OpenAI Using Tools guide](https://developers.openai.com/api/docs/guides/tools) — broader tool landscape across Responses API
- [MCP and Connectors guide](https://developers.openai.com/api/docs/guides/tools-connectors-mcp) — MCP server integration with deferred loading support

## Original Content

> [!quote]- Source Material
>
> Tool search allows the model to dynamically search for and load tools into the model's context as needed. This allows you to avoid loading all tool definitions into the model's context up front and **may help reduce overall token usage, cost, and latency**. For optimal cost and latency, tool search is designed to **preserve the model's cache**. When new tools are discovered by the model, they are injected at the end of the context window.
>
> To activate tool search, you must do two things:
>
> 1. Add `tool_search` as a tool in your `tools` array.
> 2. Mark the functions, namespaces, or MCP servers you want to make searchable with `defer_loading: true`.
>
> ### Use namespaces where possible
>
> You can use tool search with deferred functions, namespaces, or MCP servers, but we recommend using namespaces or MCP servers when possible. Our models have primarily been trained to search those surfaces, and token savings are usually more material there.
>
> At the start of a request, the model still sees the name and description of whatever is searchable. For a namespace or MCP server, that means the model sees only the namespace or server name and description at the beginning, without showing details of the individual functions contained within it until the tool search tool loads them. For an individual deferred function, the model still sees the function name and description, so in practice tool search is mostly deferring the parameter schema.
>
> For maximum token savings, we recommend grouping deferred functions into namespaces or MCP servers with clear, high-level descriptions that give the model a strong overview of what is contained within them, so it can effectively search and load only the relevant functions. As a best practice, aim to keep each namespace to fewer than 10 functions for better token efficiency and model performance.
>
> ```json
> {
>   "tools": [
>     {
>       "type": "namespace",
>       "name": "crm",
>       "description": "CRM tools for customer lookup and order management.",
>       "tools": [
>         {
>           "type": "function",
>           "name": "list_open_orders",
>           "description": "List open orders for a customer ID.",
>           "defer_loading": true,
>           "parameters": {
>             "type": "object",
>             "properties": {
>               "customer_id": { "type": "string" }
>             },
>             "required": ["customer_id"],
>             "additionalProperties": false
>           }
>         }
>       ]
>     },
>     {
>       "type": "tool_search"
>     }
>   ]
> }
> ```
>
> Namespaces can have a mix of tools that are deferred and not deferred. Tools without `defer_loading: true` are callable immediately, while deferred tools in the same namespace are loaded through tool search.
>
> ### Tool search types
>
> There are two ways to use tool search:
>
> * **Hosted tool search:** OpenAI searches across the deferred tools you declared in the request and returns the loaded subset in the same response.
> * **Client-executed tool search:** The model emits a `tool_search_call`, your application performs the lookup, and you return a matching `tool_search_output`.
>
> Start with hosted tool search if the candidate tools are already known when you create the request. Use client-executed tool search when tool discovery depends on project state, tenant state, or another system your application controls.
>
> ## Hosted tool search
>
> Hosted tool search is the simplest path when you already know the full inventory of deferred tools. You declare the deferred functions, namespaces, or MCP servers up front, add `{"type": "tool_search"}`, and let the API decide when to load a deferred tool.
>
> **Configure hosted tool search (Python):**
>
> ```python
> from openai import OpenAI
>
> client = OpenAI()
>
> crm_namespace = {
>     "type": "namespace",
>     "name": "crm",
>     "description": "CRM tools for customer lookup and order management.",
>     "tools": [
>         {
>             "type": "function",
>             "name": "get_customer_profile",
>             "description": "Fetch a customer profile by customer ID.",
>             "parameters": {
>                 "type": "object",
>                 "properties": {
>                     "customer_id": {"type": "string"},
>                 },
>                 "required": ["customer_id"],
>                 "additionalProperties": False,
>             },
>         },
>         {
>             "type": "function",
>             "name": "list_open_orders",
>             "description": "List open orders for a customer ID.",
>             "defer_loading": True,
>             "parameters": {
>                 "type": "object",
>                 "properties": {
>                     "customer_id": {"type": "string"},
>                 },
>                 "required": ["customer_id"],
>                 "additionalProperties": False,
>             },
>         },
>     ],
> }
>
> response = client.responses.create(
>     model="gpt-5.4",
>     input="List open orders for customer CUST-12345.",
>     tools=[
>         crm_namespace,
>         {"type": "tool_search"},
>     ],
>     parallel_tool_calls=False,
> )
>
> print(response.output)
> ```
>
> **Configure hosted tool search (JavaScript):**
>
> ```javascript
> import OpenAI from "openai";
>
> const client = new OpenAI();
>
> const crmNamespace = {
>   type: "namespace",
>   name: "crm",
>   description: "CRM tools for customer lookup and order management.",
>   tools: [
>     {
>       type: "function",
>       name: "get_customer_profile",
>       description: "Fetch a customer profile by customer ID.",
>       parameters: {
>         type: "object",
>         properties: {
>           customer_id: { type: "string" },
>         },
>         required: ["customer_id"],
>         additionalProperties: false,
>       },
>     },
>     {
>       type: "function",
>       name: "list_open_orders",
>       description: "List open orders for a customer ID.",
>       defer_loading: true,
>       parameters: {
>         type: "object",
>         properties: {
>           customer_id: { type: "string" },
>         },
>         required: ["customer_id"],
>         additionalProperties: false,
>       },
>     },
>   ],
> };
>
> const response = await client.responses.create({
>   model: "gpt-5.4",
>   input: "List open orders for customer CUST-12345.",
>   tools: [crmNamespace, { type: "tool_search" }],
>   parallel_tool_calls: false,
> });
>
> console.log(response.output);
> ```
>
> If the model decides it needs a deferred tool, the response includes two additional output items before the eventual function call:
>
> * `tool_search_call`, which records the hosted search step.
> * `tool_search_output`, which contains the loaded subset that becomes callable.
>
> **Hosted tool search response:**
>
> ```json
> [
>   {
>     "type": "tool_search_call",
>     "execution": "server",
>     "call_id": null,
>     "status": "completed",
>     "arguments": {
>       "paths": ["crm"]
>     }
>   },
>   {
>     "type": "tool_search_output",
>     "execution": "server",
>     "call_id": null,
>     "status": "completed",
>     "tools": [
>       {
>         "type": "namespace",
>         "name": "crm",
>         "description": "CRM tools for customer lookup and order management.",
>         "tools": [
>           {
>             "type": "function",
>             "name": "list_open_orders",
>             "description": "List open orders for a customer ID.",
>             "defer_loading": true,
>             "parameters": {
>               "type": "object",
>               "properties": {
>                 "customer_id": { "type": "string" }
>               },
>               "required": ["customer_id"],
>               "additionalProperties": false
>             }
>           }
>         ]
>       }
>     ]
>   },
>   {
>     "type": "function_call",
>     "name": "list_open_orders",
>     "namespace": "crm",
>     "call_id": "call_abc123",
>     "arguments": "{\"customer_id\":\"CUST-12345\"}"
>   }
> ]
> ```
>
> In hosted mode, `execution` is set to `server` and `call_id` is set to `null`.
>
> For more complex tasks, the model can also load multiple namespaces or MCP servers in the same `tool_search_call`. For example, if it needs functions from different namespaces to complete one task, it may choose to search and load those surfaces together before making the subsequent function calls.
>
> ## Client-executed tool search
>
> Client-executed tool search gives your application full control over how tool discovery works. This is useful when the available tools depend on information that is not practical to declare in the initial `tools` list.
>
> Configure the `tool_search` tool with `execution: "client"` and a schema for the search arguments your application expects:
>
> **Configure client-executed tool search (Python):**
>
> ```python
> from openai import OpenAI
>
> client = OpenAI()
>
> first_response = client.responses.create(
>     model="gpt-5.4",
>     input="Find the shipping ETA tool first, then use it for order_42.",
>     tools=[
>         {
>             "type": "tool_search",
>             "execution": "client",
>             "description": "Find the project-specific tools needed to continue the task.",
>             "parameters": {
>                 "type": "object",
>                 "properties": {
>                     "goal": {"type": "string"},
>                 },
>                 "required": ["goal"],
>                 "additionalProperties": False,
>             },
>         }
>     ],
>     parallel_tool_calls=False,
> )
>
> search_call = next(
>     item for item in first_response.output if item.type == "tool_search_call"
> )
>
> loaded_tools = [
>     {
>         "type": "function",
>         "name": "get_shipping_eta",
>         "description": "Look up shipping ETA details for an order.",
>         "defer_loading": True,
>         "parameters": {
>             "type": "object",
>             "properties": {
>                 "order_id": {"type": "string"},
>             },
>             "required": ["order_id"],
>             "additionalProperties": False,
>         },
>     }
> ]
>
> second_response = client.responses.create(
>     model="gpt-5.4",
>     input=[
>         *first_response.output,
>         {
>             "type": "tool_search_output",
>             "execution": "client",
>             "call_id": search_call.call_id,
>             "status": "completed",
>             "tools": loaded_tools,
>         },
>     ],
> )
>
> print(second_response.output)
> ```
>
> **Configure client-executed tool search (JavaScript):**
>
> ```javascript
> import OpenAI from "openai";
>
> const client = new OpenAI();
>
> const firstResponse = await client.responses.create({
>   model: "gpt-5.4",
>   input: "Find the shipping ETA tool first, then use it for order_42.",
>   tools: [
>     {
>       type: "tool_search",
>       execution: "client",
>       description: "Find the project-specific tools needed to continue the task.",
>       parameters: {
>         type: "object",
>         properties: {
>           goal: { type: "string" },
>         },
>         required: ["goal"],
>         additionalProperties: false,
>       },
>     },
>   ],
>   parallel_tool_calls: false,
> });
>
> const searchCall = firstResponse.output.find(
>   (item) => item.type === "tool_search_call",
> );
>
> const loadedTools = [
>   {
>     type: "function",
>     name: "get_shipping_eta",
>     description: "Look up shipping ETA details for an order.",
>     defer_loading: true,
>     parameters: {
>       type: "object",
>       properties: {
>         order_id: { type: "string" },
>       },
>       required: ["order_id"],
>       additionalProperties: false,
>     },
>   },
> ];
>
> const secondResponse = await client.responses.create({
>   model: "gpt-5.4",
>   input: [
>     ...firstResponse.output,
>     {
>       type: "tool_search_output",
>       execution: "client",
>       call_id: searchCall.call_id,
>       status: "completed",
>       tools: loadedTools,
>     },
>   ],
> });
>
> console.log(secondResponse.output);
> ```
>
> On the first turn, the model emits a `tool_search_call` and stops there:
>
> **Client tool search call:**
>
> ```json
> [
>   {
>     "type": "tool_search_call",
>     "execution": "client",
>     "call_id": "call_abc123",
>     "status": "completed",
>     "arguments": {
>       "goal": "Find the shipping ETA tool for order_42."
>     }
>   }
> ]
> ```
>
> Your application then performs the search and returns a `tool_search_output` with the tools it wants to load:
>
> **Return tool_search_output:**
>
> ```json
> [
>   {
>     "type": "tool_search_output",
>     "execution": "client",
>     "call_id": "call_abc123",
>     "status": "completed",
>     "tools": [
>       {
>         "type": "function",
>         "name": "get_shipping_eta",
>         "description": "Look up shipping ETA details for an order.",
>         "defer_loading": true,
>         "parameters": {
>           "type": "object",
>           "properties": {
>             "order_id": { "type": "string" }
>           },
>           "required": ["order_id"],
>           "additionalProperties": false
>         }
>       }
>     ]
>   }
> ]
> ```
>
> On the next turn, the loaded tool is callable like a normal function:
>
> **Loaded function call:**
>
> ```json
> [
>   {
>     "type": "function_call",
>     "name": "get_shipping_eta",
>     "namespace": "get_shipping_eta",
>     "call_id": "call_xyz456",
>     "arguments": "{\"order_id\":\"order_42\"}"
>   }
> ]
> ```
>
> In client mode, `execution` is set to `client` and `call_id` is defined. Echo the same `call_id` from the `tool_search_call` in your `tool_search_output`.
>
> ## Advanced usage
>
> ### Keep namespace descriptions clear
>
> Make namespace descriptions clear and descriptive of the use case, because the model relies on this description to decide when to load a subset of functions in that namespace. Avoid overly long descriptions. Instead, put richer detail in the deferred function descriptions that are loaded only when needed.
>
> ### Understand what gets loaded
>
> `tool_search_output.tools` contains the list of tools that were dynamically loaded by the model. The model will be able to call any of these tools in future turns, so in client mode you do not need to load the same tool again across turns. Tools that were not listed as part of this array will not be available to the model. If you want to disable a loaded tool, you can remove it from the `tool_search_output` item where you define the loaded tool set, but note that changing the loaded tool set will break the model's cache from that point forward.
>
> ### Advanced injection patterns
>
> Most integrations declare tools in the request's `tools` parameter. Client-executed tool search also supports more advanced patterns where your application returns tools that were not present in the original request. Treat this as an advanced workflow: validate the returned schemas carefully and only expose trusted tool definitions.
>
> ### Tool search and caching
>
> All tools are loaded at the end of the model's context window. This holds true for both hosted tool search and client-executed tool search. This allows the model's cache to be preserved from one request to another, lowering overall costs and boosting speed.
>
> ## Related guides
>
> * Use [function calling](https://developers.openai.com/api/docs/guides/function-calling) to define callable functions and custom tools.
> * Use [Using tools](https://developers.openai.com/api/docs/guides/tools) for the broader tool landscape across Responses.

Source: <https://developers.openai.com/api/docs/guides/tools-tool-search>
