---
created: 2026-03-12
description: SQLMesh parses SQL semantically via SQLGlot instead of treating it as text blobs, enabling compile-time validation, column-level lineage, and cross-engine transpilation — infrastructure that makes data agent workflows programmatically verifiable.
source: https://www.ssp.sh/brain/sqlmesh/
---

# Semantic SQL parsing makes data transformations programmatically validatable which is what data agents need underneath them

## Key Takeaways

SQLMesh's core insight is that treating SQL as opaque text (dbt's Jinja approach) leaves enormous value on the table. By parsing SQL into a semantic AST via SQLGlot, SQLMesh can validate queries at compile time, track column-level lineage, transpile across engines (DuckDB → BigQuery), and detect breaking changes like duplicate column names from `SELECT a.*, b.*`. For [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it|data agents that generate SQL]], this means a programmatic validation layer that catches errors before expensive warehouse runs.

Column-level lineage is particularly relevant to agentic workflows. An agent modifying an upstream model can automatically trace impact downstream — exactly the kind of metadata that [[data agents are useless without a context layer that captures business definitions and tribal knowledge|context layers need]] to make agents reliable. SQLMesh propagates even column comments through lineage, building the kind of living documentation that agents can consume.

The Python macro system replacing Jinja is a quiet win for agent-driven pipelines. Python macros are testable, type-checkable, and can return SQLGlot expression objects — far more amenable to programmatic generation than string interpolation. An agent generating or modifying transformation logic gets compile-time feedback rather than discovering errors at runtime.

Market context matters here: Fivetran acquired Tobiko Data (SQLMesh) in September 2025 under the banner of "AI-Ready Data Transformation," then acquired dbt Labs a month later. Fivetran now owns both leading SQL transformation frameworks. Meanwhile dbt's open-source future is uncertain — dbt Fusion (the next-gen engine) is closed-source, which threatens the ecosystem of orchestrators and tools built on dbt Core. SQLMesh + Dagster is emerging as the strongest fully open-source alternative.

The practical features that matter for [[context management replaces the semantic layer for data agents because it adapts from corrections|automated data workflows]]: native batched backfills (choose bucket size instead of one mega-query), CTE unit testing (test individual parts of complex models), cross-engine table diffing (invaluable for migrations), and native partitioning understanding that integrates cleanly with Dagster's asset-aware orchestration.

## External Resources

- [SQLMesh GitHub](https://github.com/SQLMesh/sqlmesh) — the main repo, backwards-compatible with dbt
- [SQLGlot](https://github.com/tobymao/sqlglot) — the SQL transpiler powering SQLMesh's semantic understanding
- [Fivetran acquires Tobiko Data](https://www.fivetran.com/press/fivetran-acquires-tobiko-data-to-power-the-next-generation-of-advanced-ai-ready-data-transformation) — "AI-Ready Data Transformation" acquisition (2025-09-03)
- [dlt-SQLMesh generator](https://dlthub.com/blog/sqlmesh-dlt-handover) — metadata handover from ingestion to transformation
- [Dagster + SQLMesh integration](https://share.snipd.com/chapter/ecb34119-9708-42dc-84cb-54298269d94a) — comparison snip from Data Engineering Podcast
- [Reddit: SQLMesh vs dbt Core](https://sh.reddit.com/r/dataengineering/comments/1j5bttx/comment/mgghrle/) — practitioner feature comparison
- [Tobiko Data blog: SQLMesh Browser UI](https://tobikodata.com/sqlmesh-ui.html)
- [Simon Späti's Digital Garden: dbt Fusion notes](https://www.ssp.sh/brain/dbt-fusion)

## Original Content

> [!quote]- Source Material
>
> *From Simon Späti's digital garden (ssp.sh/brain/sqlmesh), last updated Mar 11, 2026*
>
> Don't hack custom scripts or use half-baked tools. SQLMesh ensures accurate and efficient data pipelines with the most complete DataOps solution for transformation, testing, and collaboration.
>
> Similar to dbt but tries to understand more of the semantics of the SQLs, where dbt is just stitching together blobs of SQL, SQLMesh tries to understand the SQL statements more. That allows them to do the translation from Duckdb-SQL to BigQuery-SQL, because of that awareness.
>
> *SQLMesh Browser UI*
> ![[sqlmesh-ssp-sqlmesh-1741593765551.webp]]
>
> ### History
>
> - Tobiko Acquires Quary (2025-01-15)
> - 2025-09-03: Acquired by Fivetran: "Fivetran Acquires Tobiko Data to Power the Next Generation of Advanced, AI-Ready Data Transformation"
>
> *SQLMesh overview diagram*
> ![[sqlmesh-ssp-img-sqlmesh-1773273056523.webp]]
>
> ### Plans (Environments)
>
> SQLMesh concepts with plans that apply to different environments (prod, dev) are elegant. Even `fetchdf` is integrated into the CLI. Also, SQLMesh auto-detects the new columns as non-breaking and simply applies the (virtual) changes.
>
> *Plans and virtual environments — non-breaking change detection*
> ![[sqlmesh-ssp-sqlmesh-20241023143759474.webp]]
>
> ### Column-Level Lineage
>
> Comments can be lineaged, with just adding a comment on previous column.
>
> ### Semantic Understanding
>
> SQLMesh actually understands the SQL you write and improves developer productivity by finding issues at compile time. Built-in column-level lineage provides a deeper understanding of your data model and transpilation makes it easy to run your SQL across multiple engines.
>
> *Semantic understanding — compile-time validation*
> ![[sqlmesh-ssp-sqlmesh-20241002175007918.webp]]
>
> ### Using SQLGlot expressions
>
> SQLMesh automatically parses strings returned by Python macro functions into SQLGlot expressions so they can be incorporated into the model query's semantic representation. Functions can also return SQLGlot expressions directly.
>
> Example — a macro function using the `BETWEEN` operator:
>
> ```python
> from sqlmesh import macro
>
> @macro()
> def between_where(evaluator, column_name, low_val, high_val):
>     return f"{column_name} BETWEEN {low_val} AND {high_val}"
> ```
>
> Called in a query: `SELECT a FROM table WHERE @between_where(a, 1, 3)`
> Renders to: `SELECT a FROM table WHERE a BETWEEN 1 and 3`
>
> Alternatively, returning a SQLGlot expression:
>
> ```python
> @macro()
> def between_where(evaluator, column, low_val, high_val):
>     return column.between(low_val, high_val)
> ```
>
> ### Integrations
>
> - Dagster: SQL Mesh and Dagster comparison
> - dlt: dlt-SQLMesh generator — metadata handover from ingestion to transformation
>
> ### Features (from Reddit practitioner review)
>
> 1. **Python macros** — better than Jinja, testable and type-checkable
> 2. **Compile-time SQL validation** — reduces invalid SQL reaching production
> 3. **Breaking change detection** — catches duplicate columns from `SELECT a.*, b.*` upstream
> 4. **CTE unit testing** — test individual CTEs in complex models; run tests on DuckDB instead of hitting the warehouse
> 5. **Native table diffing** — between prod and dev, even cross-engine (useful for migrations like Redshift → Snowflake)
> 6. **Native batched backfills** — pick bucket size (e.g., 7 days) instead of one mega-query
> 7. **Native partitioning understanding** — integrates with Dagster, handles intraday partitioning, ensures completeness
> 8. **Multi-engine repo support** (emerging) — e.g., Iceberg catalog with traditional warehouse + Trino for federated queries
>
> ### dbt vs SQLMesh
>
> - dbt announced dbt Fusion (closed-source, Rust-based). dbt Core (open source) will probably be unmaintained over time as all new features go into dbt Fusion, which needs paid dbt Cloud.
> - dbt Fusion is similar to SQLMesh — Rust based, super fast, does compiling features like checking data types ahead of runtime. But it's not fully open-source.
> - SQLMesh has great momentum. They created and use SQLGlot (open-source transpiler) that can read almost any SQL syntax and translate to others.
> - SQLMesh is very CLI-heavy — good for embedding in Kestra or similar, less friendly for non-technical users. But they have column-level lineage, plans for environments, and semantic understanding that is quite sophisticated.
>
> "I have used dbt much more than SQLMesh, and dbt is for sure the market leader. But if you start out, it's a really good idea to check out SQLMesh too."
>
> *— Simon Späti, ssp.sh/brain/sqlmesh*
> *Source: https://www.ssp.sh/brain/sqlmesh/*
