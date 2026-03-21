---
created: 2026-03-21
source: https://github.com/dlt-hub/dlt
type: resource
tags: [data-loading, etl, python, pipelines]
status: unread
---

## What it is

dlt (data load tool) is an open-source Python library that automates data loading from messy sources (REST APIs, SQL databases, cloud storage, nested Python structures) into well-structured datasets on popular destinations like DuckDB, BigQuery, Snowflake, and more. It handles schema inference, data normalization, and nested data flattening automatically.

## Why it's interesting

It's a lightweight, drop-anywhere ETL library that eliminates boilerplate — you can run it in a notebook, Lambda function, Airflow DAG, or locally with just `pip install dlt`. The library auto-infers schemas, handles incremental loading and schema evolution, and supports 5000+ sources via its ecosystem. It's also built to be LLM-friendly with an explicit LLM-native workflow for generating pipeline code.

## How it works

A dlt pipeline has three stages: **Extract** pulls data from a source using Python generators or the built-in REST API client, producing raw Python dicts/lists. **Normalize** infers the schema from the data, flattens nested structures into relational tables, and applies data type detection and schema evolution rules. **Load** writes the normalized data to the configured destination (DuckDB, Postgres, BigQuery, etc.) using optimized bulk loading. Incremental loading is handled via cursor-based or merge strategies so only new/changed data is processed on subsequent runs. Schema contracts let you enforce or relax rules on what data shapes are accepted.

## Key links

- [GitHub](https://github.com/dlt-hub/dlt)
- [Docs](https://dlthub.com/docs)
- [Community Slack](https://dlthub.com/community)
- [Colab Demo](https://colab.research.google.com/drive/1NfSB1DpwbbHX9_t5vlalBTf13utwpMGx?usp=sharing)

## Notes

- Apache 2.0 licensed, supports Python 3.9–3.14
- Could be useful for agent data pipelines — loading structured outputs into analytical stores
- LLM-native workflow documented at dlthub.com/docs/dlt-ecosystem/llm-tooling/llm-native-workflow
