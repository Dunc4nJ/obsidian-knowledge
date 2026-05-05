---
created: 2026-05-05
description: Leonie Monigatti studied Mintlify's ChromaFs blog post and shipped an open-source POC implementing the same four-layer architecture over Elasticsearch instead of Chroma, validating that the virtual-filesystem-over-search-index pattern ports across search backends and filling the public-reference-code gap left by the original article.
source: https://x.com/helloiamleonie/status/2051634317097414833
type: synthesis
---

## Key Takeaways

The [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|Mintlify ChromaFs design]] ports cleanly to Elasticsearch. Leonie kept the same four-layer split — Agent → `just-bash` shell → `IFileSystem` impl → search index — and swapped only the data layer. That suggests the durable abstraction is "UNIX commands as the agent interface, search-index queries as the implementation" rather than anything specific to Chroma or vector search. A relational DB, OpenSearch, or hybrid index could slot in the same way, which is consistent with how [[SMFS makes grep itself a vector query so agents get RAG without learning a new tool|SMFS]] and [[NIA Docs turns web documentation into a filesystem that agents can grep, cat, and code against|NIA Docs]] each pick a different backend behind the same shell-shaped interface.

The Mintlify article shipped without source code, and that gap was load-bearing — Leonie cites "burned through a lot of tokens" to reproduce the design. `iamleonie/elasticsearch-fs` is now the public reference implementation the pattern was missing, so the artifact future implementers fork from is OSS code rather than a marketing blog. This matters more than usual because [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|filesystem-as-database-frontend]] is becoming a category, and category formation needs runnable references.

Independent reimplementation by an unaffiliated third party is a useful signal that a published architecture generalizes. Mintlify's blog described one production deployment over Chroma; Leonie's POC over Elasticsearch confirms the design isn't a Chroma-specific accident and isn't a Mintlify-specific accident — the four-layer pattern survives a backend swap by someone working only from the blog.

## External Resources

- [Implementing a virtual filesystem over Elasticsearch](https://leoniemonigatti.com/blog/virtual-filesystem-elasticsearch.html) — Leonie's blog post walking through `ElasticsearchFs`: access control via Elasticsearch Document Level Security, in-memory path tree from a `__path_tree__` metadata document, single-call `cat` via slug lookup, follows LangChain's documented virtual-filesystem design guidelines (absolute path normalization, structured errors, `EROFS` on writes)
- [iamleonie/elasticsearch-fs](https://github.com/iamleonie/elasticsearch-fs) — open-source POC repository, the public reference implementation the Mintlify article didn't ship
- [Building a Virtual Filesystem for Mintlify's AI Assistant](https://www.mintlify.com/blog/how-we-built-a-virtual-filesystem-for-our-assistant) — original Mintlify writeup that inspired the reimplementation
- [just-bash by Vercel Labs](https://github.com/vercel-labs/just-bash) — the TypeScript bash reimplementation with pluggable `IFileSystem` interface that both ChromaFs and ElasticsearchFs build on
- [LangChain virtual filesystem design guidelines](https://docs.langchain.com/oss/python/deepagents/backends#use-a-virtual-filesystem) — documented patterns Leonie cross-references (absolute paths, in-memory `ls`/`glob`, structured error types)

## Original Content

> **@densumesh** (Dens Sumesh) — Thu Apr 2, 2026 · 1080 likes · 94 retweets · 47 replies
>
> Article: Building a Virtual Filesystem for Mintlify's AI Assistant

*Mintlify assistant file system — doc tree with grep command*
![[densumesh-637016-001.jpg]]

> [!quote]- Source Material (Mintlify article quoted in tweet)

RAG is great, until it isn't.

Our assistant could only retrieve chunks of text that matched a query. If the answer lived across multiple pages, or the user needed exact syntax that didn't land in a top-K result, it was stuck. We wanted it to explore docs the way you'd explore a codebase.

Agents are [converging on filesystems as their primary interface](https://arxiv.org/abs/2601.11672) because grep, cat, ls, and find are all an agent needs. If each doc page is a file and each section is a directory, the agent can search for exact strings, read full pages, and traverse the structure on its own. We just needed a filesystem that mirrored the live docs site.

#### The Container Bottleneck

The obvious way to do this is to just give the agent a real filesystem. Most harnesses solve this by spinning up an isolated sandbox and cloning the repo. We already use sandboxes for asynchronous background agents where latency is an afterthought, but for a frontend assistant where a user is staring at a loading spinner, the approach falls apart. Our p90 session creation time (including GitHub clone and other setup) was ~46 seconds.

Beyond latency, dedicated micro-VMs for reading static documentation introduced a serious infrastructure bill.

At 850,000 conversations a month, even a minimal setup (1 vCPU, 2 GiB RAM, 5-minute session lifetime) would put us north of $70,000 a year based on [Daytona's per-second sandbox pricing](https://www.daytona.io/pricing) ($0.0504/h per vCPU, $0.0162/h per GiB RAM). Longer session times double that. (This is based on a purely naive approach, a true production workflow would probably have warm pools and container sharing, but the point still stands)

We needed the filesystem workflow to be instant and cheap, which meant rethinking the filesystem itself.

#### Faking a Shell

The agent doesn't need a real filesystem; it just needs the illusion of one. Our documentation was already indexed, chunked, and stored in a Chroma database to power our search, so we built ChromaFs: a virtual filesystem that intercepts UNIX commands and translates them into queries against that same database. Session creation dropped from ~46 seconds to ~100 milliseconds, and since ChromaFs reuses infrastructure we already pay for, the marginal per-conversation compute cost is zero.

ChromaFs is built on [just-bash](https://github.com/vercel-labs/just-bash) by Vercel Labs (shoutout [Malte](https://x.com/cramforce)!), a TypeScript reimplementation of bash that supports grep, cat, ls, find, cd, and more. just-bash exposes a pluggable IFileSystem interface, so it handles all the parsing, piping, and flag logic while ChromaFs translates every underlying filesystem call into a Chroma query.

```typescript
export class ChromaFs implements IFileSystem {
  private files = new Set<string>();
  private dirs = new Map<string, string[]>();

  async readFile(path: string): Promise<string> {
     this.assertInit();
     const normalized = normalizePath(path);

    // Serve from cache or fetch from Chroma
    const slug = normalized.replace(/\\.mdx$/, '').slice(1);

    // Pages are chunked in Chroma. Reassemble them on the fly:
    const results = await this.collection.get<ChunkMetadata>({
      where: { page: slug },
      include: [IncludeEnum.documents, IncludeEnum.metadatas],
    });

    const chunks = results.ids
      .map((id, i) => ({
        document: results.documents[i] ?? '',
        chunkIndex: parseInt(String(results.metadatas[i]?.chunk_index ?? 0), 10),
      }))
      .sort((a, b) => a.chunkIndex - b.chunkIndex);

    return chunks.map((c) => c.document).join('');

  }

  // Enforce completely stateless, read-only interaction
  async writeFile(): Promise<void> { throw erofs(); }
  async appendFile(): Promise<void> { throw erofs(); }
  async mkdir(): Promise<void> { throw erofs(); }
  async rm(): Promise<void> { throw erofs(); }
}
```

#### How it works

Bootstrapping the Directory Tree

ChromaFs needs to know what files exist before the agent runs a single command. We store the entire file tree as a gzipped JSON document (`__path_tree__`) inside the Chroma collection:

```json
{
  "auth/oauth": { "isPublic": true, "groups": [] },
  "auth/api-keys": { "isPublic": true, "groups": [] },
  "internal/billing": { "isPublic": false, "groups": ["admin", "billing"] },
  "api-reference/endpoints/users": { "isPublic": true, "groups": [] }
}
```

On init, the server fetches and decompresses this document into two in-memory structures: a `Set<string>` of file paths and a `Map<string, string[]>` mapping directories to children.

Once built, ls, cd, and find resolve in local memory with no network calls. The tree is cached, so subsequent sessions for the same site skip the Chroma fetch entirely.

Access Control

Notice the isPublic and groups fields in the path tree. Before building the file tree, ChromaFs prunes the file tree based on the current user's permissions and applies a matching filter to all subsequent Chroma queries.

In a real sandbox, this level of per-user access control would require managing Linux user groups, chmod permissions, or maintaining isolated container images per customer tier. In ChromaFs it's a few lines of filtering before buildFileTree runs.

Reassembling Pages from Chunks

Pages in Chroma are split into chunks for embedding, so when the agent runs `cat /auth/oauth.mdx`, ChromaFs fetches all chunks with a matching page slug, sorts by chunk_index, and joins them into the full page. Results are cached so repeated reads during grep workflows never hit the database twice.

Not every file needs to exist in Chroma. We register lazy file pointers that resolve on access for large OpenAPI specs stored in customers' S3 buckets. The agent sees v2.json in /api-specs/, but the content only fetches when it runs cat.

Every write operation throws an EROFS (Read-Only File System) error. The agent explores freely but can never mutate documentation, which makes the system stateless with no session cleanup and no risk of one agent corrupting another's view.

#### Optimizing Grep

cat and ls are straightforward to virtualize, but grep -r would be far too slow if it naively scanned every file over the network. We intercept just-bash's grep, parse the flags with yargs-parser, and translate them into a Chroma query (`$contains` for fixed strings, `$regex` for patterns).

Chroma acts as a coarse filter that identifies which files might contain the hit, and we bulkPrefetch those matching chunks into a Redis cache. From there, we rewrite the grep command to target only the matched files and hand it back to just-bash for fine filter in-memory execution, which means large recursive queries complete in milliseconds.

```typescript
const chromaFilter = toChromaFilter(
  scannedArgs.patterns,
  scannedArgs.fixedStrings,
  scannedArgs.ignoreCase
);

// 1. Coarse Filter: Ask Chroma for slugs matching the string/regex
const matchedSlugs = await chromaFs.findMatchingFiles(chromaFilter, slugsUnderDirs);
if (matchedSlugs.length === 0) return { stdout: '', exitCode: 1 };

// 2. Prefetch: Pull the chunked files into local cache concurrently
await chromaFs.bulkPrefetch(matchedSlugs);

// 3. Fine Filter: Narrow the arguments to ONLY the resolved hits
const matchedPaths = matchedSlugs.map((s) => '/' + s + '.mdx');
const narrowedArgs = [...args, ...matchedPaths]; // e.g. ["-i", "OAuth", "/docs/auth.mdx"]

// 4. Exec: Let the in-memory RegExp engine format the final output
return execBuiltin(narrowedArgs, ctx);
```

#### Conclusion

ChromaFs powers the documentation assistant for hundreds of thousands of users across 30,000+ conversations a day. By replacing sandboxes with a virtual filesystem over our existing Chroma database, we got instant session creation, zero marginal compute cost, and built-in RBAC without any new infrastructure.

Try it on any Mintlify docs site, or mintlify.com/docs.

[Read the full article at: [https://www.mintlify.com/blog/how-we-built-a-virtual-filesystem-for-our-assistant](https://www.mintlify.com/blog/how-we-built-a-virtual-filesystem-for-our-assistant)]

> Tweet: <https://x.com/densumesh/status/2039765361533637016>

---

> **@helloiamleonie** (Leonie) — Tue May 5, 2026 · 453 likes · 50 retweets · 10 replies
>
> Quote-tweeting [@densumesh](https://x.com/densumesh/status/2039765361533637016)

> [!quote]- Source Material

This is a very cool article describing how they built a virtual filesystem for their agent.

But there was no code.

So, I studied the blog, burned through a lot of tokens, and implemented a POC. Here is the result:

A virtual filesystem over Elasticsearch.

Blog: <https://leoniemonigatti.com/blog/virtual-filesystem-elasticsearch.html>
GitHub repo: <https://github.com/iamleonie/elasticsearch-fs>

> Quote tweet @densumesh:
> Article: Building a Virtual Filesystem for Mintlify's AI Assistant
> <https://x.com/densumesh/status/2039765361533637016>

*Architecture diagram from Leonie's blog post — the four-layer ElasticsearchFs stack*
![[helloiamleonie-414833-001.jpg]]

> Tweet: <https://x.com/helloiamleonie/status/2051634317097414833>
