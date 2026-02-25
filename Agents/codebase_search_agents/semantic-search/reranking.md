# Rerank Model

Reorder search results by relevance with our specialized reranking API

# [​](#overview) Overview

The Rerank API improves search quality by reordering candidate results based on their relevance to a query. Our latest `morph-rerank-v3` model achieves state-of-the-art performance across all coding benchmarks for accuracy:speed ratio - no rerank model comes close. It's designed specifically for code-related content and goes beyond traditional keyword matching to understand semantic intent.

## [​](#custom-api-endpoint) Custom API Endpoint

Unlike our Apply and Embedding models that use OpenAI-compatible APIs, the Rerank model uses a custom endpoint designed specifically for reranking tasks. It is Cohere client compatible.

## [​](#endpoint-reference) Endpoint Reference

Python

JavaScript

cURL

```
import requests

def rerank_results(query: str, documents: list[str], top_n: int = 5):
    response = requests.post(
        "https://api.morphllm.com/v1/rerank",
        headers={
            "Authorization": f"Bearer your-morph-api-key",
            "Content-Type": "application/json"
        },
        json={
            "model": "morph-rerank-v3",
            "query": query,
            "documents": documents,
            "top_n": top_n
        }
    )

    return response.json()

# Example usage
query = "How to implement authentication in Express.js"
documents = [
    "This Express.js middleware provides authentication using JWT tokens and protects routes.",
    "Express.js is a popular web framework for Node.js applications.",
    "Authentication is the process of verifying a user's identity.",
    "This example shows how to build a RESTful API with Express.js.",
    "Learn how to implement OAuth2 authentication in your Express.js application.",
    "Implementing user authentication with Passport.js in Express applications."
]

results = rerank_results(query, documents)
print(results)
```

## [​](#parameters) Parameters

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `model` | string | Yes | The model ID to use for reranking. Use `morph-rerank-v3` (latest) or `morph-rerank-v3`. |
| `query` | string | Yes | The search query to compare documents against. |
| `documents` | array | No\* | An array of document strings to be reranked. Required if `embedding_ids` is not provided. |
| `embedding_ids` | array | No\* | An array of embedding IDs to rerank. Required if `documents` is not provided. Remote content storage must be enabled. |
| `top_n` | integer | No | Number of top results to return. Default is all documents. |

\* Either `documents` or `embedding_ids` must be provided.

## [​](#using-embedding-ids) Using Embedding IDs

When you have previously generated embeddings with Morph's embedding model, you can use the embedding IDs for reranking:

```
async function rerankWithEmbeddingIds(query, embeddingIds, topN = 5) {
  const response = await fetch("https://api.morphllm.com/v1/rerank", {
    method: "POST",
    headers: {
      Authorization: "Bearer your-morph-api-key",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "morph-rerank-v3",
      query: query,
      embedding_ids: embeddingIds,
      top_n: topN,
    }),
  });

  return await response.json();
}

// Example with embedding IDs
const query = "React state management patterns";
const embeddingIds = [
  "emb_123456789",
  "emb_987654321",
  "emb_456789123",
  "emb_789123456",
  "emb_321654987",
];

rerankWithEmbeddingIds(query, embeddingIds, 3).then((results) =>
  console.log(results)
);
```

## [​](#remote-content-storage) Remote Content Storage

To use embedding IDs for reranking, you must enable remote content storage in your account settings. This allows Morph to retrieve the content associated with each embedding ID for reranking purposes.
Benefits of using embedding IDs:

* **Reduced payload size**: Avoid sending large document content in each request
* **Better integration**: Seamlessly works with content that was previously embedded
* **Security**: Content is securely stored within your account's storage
* **Convenience**: No need to maintain document content separately from embeddings

## [​](#response-format) Response Format

```
{
  "model": "morph-rerank-v3",
  "results": [
    {
      "index": 0,
      "document": "This Express.js middleware provides authentication using JWT tokens and protects routes.",
      "relevance_score": 0.92
    },
    {
      "index": 5,
      "document": "Implementing user authentication with Passport.js in Express applications.",
      "relevance_score": 0.87
    },
    {
      "index": 4,
      "document": "Learn how to implement OAuth2 authentication in your Express.js application.",
      "relevance_score": 0.79
    }
  ]
}
```

## [​](#features) Features

### [​](#morph-rerank-v3-latest) morph-rerank-v3 (Latest)

* **State-of-the-Art Performance**: Achieves SoTA results across all coding benchmarks for accuracy:speed ratio - no rerank model comes close
* **Unmatched Speed**: Fastest reranking inference in the market while delivering superior accuracy
* **Enhanced Context Understanding**: Improved semantic understanding of code relationships and intent

### [​](#core-features-all-models) Core Features (All Models)

* **Code-Aware**: Specifically optimized for ranking code-related content
* **Context Understanding**: Considers the full context of both query and documents
* **Relevance Scoring**: Provides numerical scores indicating relevance
* **Efficient Processing**: Optimized for quick reranking of large result sets
* **Language Agnostic**: Works with all major programming languages
* **Embedding ID Support**: Integrates with previously generated embeddings
* **Remote Content Storage**: Option to use securely stored content with embedding IDs

## [​](#integration-with-search-systems) Integration with Search Systems

The Rerank model is typically used as a second-pass ranking system after an initial retrieval step:

1. **Initial Retrieval**: Use embeddings or keyword search to retrieve an initial set of candidates
2. **Reranking**: Apply the Rerank model to sort the candidates by relevance to the query
3. **Presentation**: Display the reranked results to the user

This two-stage approach combines the efficiency of initial retrieval methods with the accuracy of deep neural reranking models.

For best code search performance, we recommend using [WarpGrep](/sdk/components/warp-grep/index) — our intelligent code search tool that combines fast retrieval with automatic reranking. WarpGrep handles the entire search pipeline for you, delivering 20x faster results than stock grepping.
