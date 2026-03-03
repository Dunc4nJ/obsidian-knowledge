---
created: 2026-03-03
title: Part 1: Designing a Production-Grade Agentic MLOps System
source: https://kmeanskaran.substack.com/p/part-1-designing-an-agentic-mlops
source_type: substack
source_author: K-Means Karan
published: 2026-01-04
---

## Part 2

Continue the series here: [[part-2-deploying-a-production-grade-agentic-mlops-system-on-aws|Part 2: Deploying a Production-Grade Agentic MLOps System on AWS]].

## Summary

This is a practical production-oriented architecture post describing how to build an end-to-end stock forecasting + reporting system using a dedicated LSTM model for time-series prediction and a separate Agentic AI layer for report synthesis, with attention to modular APIs, caching, drift handling, observability, and deployment concerns.

## Source URL

<https://open.substack.com/pub/kmeanskaran/p/part-1-designing-an-agentic-mlops?r=193n20&utm_medium=ios>

## Original Content

> “How to design a ML system?”
> “What is MLOps? and how can I learn?”
> “How to work outside Jupyter Notebook?”
> “What tools do I need?”
> These are some of the most frequently asked questions by ML practitioners who want to design and build end-to-end machine learning systems, including MLOps.
> To address this, I designed a production-grade, end-to-end ML and Agentic AI project. This is Part 1, where I explain how to think about system design and decision-making while working on real-world ML projects.
> In Part 2, I will cover deployment on AWS.
> For more such updates, follow me on [X](http://x.com/@kmeanskaran).

> **BEFORE READING THIS BLOG:**
> 1. [Watch this live demo video](https://x.com/kmeanskaran/status/2005977660929999325?s=20)
> 2. [See the system design doc](https://github.com/karan842/stock-agent-ops/blob/master/doc/system_design.md)

When we say Machine Learning, many people think only about model.fit() and Jupyter notebooks. That is exactly where the difference between research ML and applied ML begins.
If you want to work in startups, big tech, or on the applied side of ML where systems directly drive business value, this article is written for you.

Let’s begin.
> Design a Stock Agent system that predicts five-day stock performance and generates a Bloomberg-style forecast report.
> The article opens with a practical system scope and data/model constraints framing for production use.

In this project, I am designing a Stock Agent that generates a Bloomberg-style financial report for the next five days of stock performance. It includes metrics such as Open, High, Low, Close, and other derived indicators.
>
> Here is the interesting part. We are not using LLMs or any generative AI model to predict stock prices. Instead, we use an LSTM-based time series model for forecasting. This makes the project a strong combination of classical machine learning and Agentic AI.

Throughout this article, we will focus on how to design this problem for a production-grade environment. We will also cover edge cases and system-level considerations that most people tend to ignore, but which matter the most in real-world ML systems.

> **DISCLAIMER:**
>
> This project focuses on building an end-to-end machine learning system rather than maximizing prediction accuracy. While I do consider the quality and performance of the ML model, this work is intended as a proof of concept, with primary emphasis on system design and engineering decisions.
>
> You are free to experiment with models other than LSTM or apply hyperparameter tuning to improve performance. This system should not be used for making real stock trading decisions. It is created purely for learning and educational purposes.
>
> I am human and I do make mistakes. If you notice any issues or have suggestions for improvement, please feel free to share them in the comments.

Design a system that predicts five-day stock performance and delivers a clean UI where users can input a stock ticker. The system generates a Bloomberg-style report that includes next week’s forecasted prices, current market news, sentiment classification such as Bullish, Bearish, or Neutral, and a visual chart for the forecast.
That defines the problem clearly.
Now the next step is to design the framework and structure the code into well-defined modules, with each component handling a specific responsibility. In real-world production systems, different teams work on different modules, and clean separation is critical for scalability and maintainability.

Let’s start designing the system.

Looking at the requirements, we need two core outputs: forecasted stock prices and a structured financial report. This naturally leads us to two major ML components in the system.

- A classical machine learning model for time series forecasting.
- An Agentic AI layer to generate a financial report based on the model outputs and market context.

For time series forecasting, the most commonly used models are SARIMAX, Prophet, and LSTM. I chose LSTM, and here is why.
We are working with stock market data, which we source from the well-known Yahoo Finance API. Since we are forecasting US stocks, it is important to understand broader market behavior. Every stock market has an index that reflects overall trends, economic signals, and technical patterns. In the case of the US market, the S&P 500 serves this role.

Because LSTM is a neural network, it allows us to apply transfer learning. We first train an LSTM model on the S&P 500 index, which acts as the parent model. This model learns general market behavior. By freezing its weights, we then train child models for individual stocks such as Apple or Nvidia. This helps child models benefit from broader market knowledge while adapting to stock-specific patterns.

For experimentation, tracking, and storing model artifacts, we use MLflow along with DagsHub.
Now that the core decisions are clear, let’s look at the high-level system design.

![High-level system design diagram]
> ![[design-agentic-mlops-001.jpg]]
> Figure 1: High-level system architecture showing training/inference flow, ML components, and interfaces.

Feeling confused? I have already documented a complete, detailed system-level design and explanation in the GitHub repository. For deeper technical details, I recommend reading that first.

To train the model, we begin with feature engineering and preprocessing. This step focuses on generating meaningful features that directly impact forecasting performance. After that, we move into model training using LSTM along with transfer learning, which we discussed earlier.

Moving forward, we need a robust inference pipeline. This pipeline uses an online feature store powered by Feast to serve weekly stock predictions in a reliable and scalable manner.
So far, we have covered training and inference. However, real engineering begins after this point, especially when we integrate Agentic AI and design the backend systems that support it.

Let’s go through these components one by one.

A common question I often get is why we do not use Agentic AI directly for both forecasting and report generation. After all, it is easy to integrate Agentic AI with the Yahoo Finance API and let it do everything.

This is a good question, and it highlights where many startups and engineering teams fail.

LLMs and Agentic AI are not the solution to every AI problem. They are excellent at tasks such as question answering with given context, summarizing information, and extracting or scraping textual data from the internet. However, they are not well suited for learning continuous and complex temporal patterns.
Stock price forecasting is exactly that kind of problem. In fact, Agentic AI should not be used for forecasting at all.

Instead, the right approach is to use a dedicated time series model for prediction and then pass the forecasted outputs to an Agentic AI layer. That is precisely what we do here.

The LSTM model generates the future price predictions. These outputs are then provided to the Agentic AI, whose responsibility is to gather relevant market news for the given stock ticker, analyze sentiment, and generate a structured financial report. Additionally, I use a critic agent to evaluate the quality and consistency of the generated report.
This is how classical machine learning using LSTM and Agentic AI are integrated in a practical, production-oriented system.

If you think I contribute in your learning, then feel free to sponsor me

![Sponsor/branding image]
> ![[design-agentic-mlops-002.png]]
> Figure 2: Sponsor/CTA graphic shown in the post.

There is no point in repeating everything from scratch, as I have already defined everything from A to Z in the system design document.
But let me share the key points:

- We need a microservice architecture for this project, as we are connecting multiple independent components. ML systems are hard to debug, and a monolithic architecture is not recommended.
- Keep parent and child training and prediction APIs separate.
- Connect Redis for caching forecast outputs.
- Use Qdrant to store generated stock reports in a vector database for ticker-based filtering and caching. Here, we do not need semantic caching, as we are caching reports for individual stocks.
- After receiving a stock name request, first check whether the model output is present in Redis. If not, train the model from scratch. While doing this, check whether parent model weights are present. If not: train the parent model → train the child model using parent weights → generate predictions → store them in Redis → call the Agentic AI API to fetch data from Redis → generate a financial report → serve it to the UI → store the report in Qdrant.
- We also provide additional APIs, such as hard delete, to remove all model weights and flush both Qdrant and Redis.
- The backend is asynchronous, but this is not ideal when handling a large number of concurrent requests. That is why we use rate limiting with different request limits for training and inference endpoints.
- Finally, we use Docker to containerize the backend application.

This is one of the most important parts of an ML system. In most ML pipelines, it is rarely discussed or properly implemented. However, as you move toward infrastructure-level and enterprise-grade ML, this becomes a necessity.

In simple terms, observability is used to monitor the overall health of the system. For ML systems, this also includes data drift and model drift detection. Since we are using Agentic AI, evaluation of agent outputs is also required. Along with that, monitoring backend and system health is mandatory.
For this project, we focus only on data drift detection for the parent model. This is because we do not keep the same parent model for more than a week, and child models can be retrained whenever required. This keeps the setup simple.
For general system monitoring, I am using Prometheus and Grafana.

Here, we have two primary frontends:

- A user interface for generating stock reports, focused on end users.
- A monitoring dashboard for training the parent model, detecting data drift, evaluating generated reports, and viewing system logs, focused on the ML team.

![Dual UI for users and ML engineers]
> ![[design-agentic-mlops-003.jpg]]
> Figure 3: Frontend screenshots showing user-facing reporting UI and internal monitoring dashboard.

- The LSTM model is underfitted and needs improvement.
- Model versioning is implemented in the code but is not actively used.
- Cron jobs are required for parent model training and data-drift-based retraining.
- Better evaluation mechanisms are needed for Agentic AI outputs.

- Always think from a business perspective.
- The more fancy tools you use, the harder debugging becomes.
- Use AI for coding, but you need to be very strong in system design.
- AI agents are not the solution to every problem, but you should always evaluate where they fit.
- Write code outside Jupyter notebooks.
- I built this project with the help of ChatGPT, AntiGravity, and Grok, without following any tutorial.

This is just Part 1. In Part 2, I will deploy the entire system on AWS using services such as EC2, ECR, and EKS. I will also use Terraform for infrastructure provisioning. That will be covered in the next article, which I will release soon.

If you liked this blog post, I am confident you will enjoy my other content as well.

- [Visit my website](http://kmeanskaran.com)
- [Follow me on X](http://x.com/@kmeanskaran)
- [Follow me on LinkedIn](http://linkedin.com/in/kmeanskaran)
- [Buy me a coffee](https://buymeacoffee.com/kmeanskaran)
Until next time :)

- [Original post](https://kmeanskaran.substack.com/p/part-1-designing-an-agentic-mlops)
