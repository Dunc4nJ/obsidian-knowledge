---
created: 2026-02-25
type: project-doc
description: "Morph's embedding API converts code and text into semantic vectors using the morph-embedding-v3 model for search and similarity tasks."
---
# Embedding Model

Create semantic embeddings for code with our OpenAI-compatible API

# [​](#overview) Overview

The Embedding API converts code and text into high-dimensional vectors that capture semantic meaning. Our latest `morph-embedding-v3` model delivers state-of-the-art performance on code retrieval tasks, enabling powerful search, clustering, and similarity operations for code-related applications.

## [​](#endpoint-reference) Endpoint Reference

Python

JavaScript

cURL

```
from openai import OpenAI

# Initialize the OpenAI client with Morph's API endpoint
client = OpenAI(
    api_key="your-morph-api-key",
    base_url="https://api.morphllm.com/v1"
)

def get_embeddings(text: str) -> list[float]:
    response = client.embeddings.create(
        model="morph-embedding-v3",
        input=text
    )
    return response.data[0].embedding

# Example: Get embeddings for code chunks
def embed_code_chunks(code_chunks: list[str]) -> list[dict]:
    results = []

    for chunk in code_chunks:
        embedding = get_embeddings(chunk)
        results.append({
            "text": chunk,
            "embedding": embedding
        })

    return results

# Store these embeddings in a vector database of your choice
```

## [​](#parameters) Parameters

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `model` | string | Yes | The model ID to use for embedding generation. Use `morph-embedding-v3` (latest) or `morph-embedding-v3`. |
| `input` | string or array | Yes | The text to generate embeddings for. Can be a string or an array of strings. |
| `encoding_format` | string | No | The format in which the embeddings are returned. Options are `float` and `base64`. Default is `float`. |

## [​](#response-format) Response Format

```
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "embedding": [0.0023064255, -0.009327292, ...],
      "index": 0
    }
  ],
  "model": "morph-embedding-v3",
  "usage": {
    "prompt_tokens": 8,
    "total_tokens": 8
  }
}
```

## [​](#features) Features

### [​](#morph-embedding-v3-latest) morph-embedding-v3 (Latest)

* **State-of-the-Art Performance**: Achieves SoTA results across all coding benchmarks for accuracy:speed ratio - no embedding model comes close
* **1024 Dimensions**: Optimal dimensionality for rich semantic representation while maintaining efficiency
* **Unmatched Speed**: Fastest inference in the market while delivering superior accuracy on code retrieval tasks
* **Enhanced Code Understanding**: Improved semantic understanding of code structure and intent
* **Better Cross-Language Support**: Superior understanding of relationships between different programming languages
* **Improved Context Handling**: Better performance on longer code snippets and complex codebases

### [​](#core-features-all-models) Core Features (All Models)

* **Code Optimized**: Specially trained to understand programming languages and code semantics
* **High Dimensionality**: Creates rich embeddings that capture nuanced relationships between code concepts
* **Language Support**: Works with all major programming languages including Python, JavaScript, Java, Go, and more
* **Contextual Understanding**: Captures semantic meanings rather than just syntactic similarities
* **Batch Processing**: Efficiently processes multiple inputs in a single API call

## [​](#common-use-cases) Common Use Cases

* **Semantic Code Search**: Create powerful code search systems that understand intent
* **Similar Code Detection**: Find similar implementations or potential code duplications
* **Code Clustering**: Group related code snippets for organization or analysis
* **Relevance Ranking**: Rank code snippets by relevance to a query
* **Concept Tagging**: Automatically tag code with relevant concepts or categories
