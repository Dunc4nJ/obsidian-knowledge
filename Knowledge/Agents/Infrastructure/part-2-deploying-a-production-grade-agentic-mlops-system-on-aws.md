---
created: 2026-03-03
description: Part 2 of a Stock-Agent-Ops series on taking an Agentic MLOps system from local Docker Compose to AWS production with EKS, Terraform, Bedrock, and CI/CD.
source: https://kmeanskaran.substack.com/p/part-2-deploying-a-production-grade?r=2jbr0u&utm_medium=ios&triedRedirect=true
type: deployment
---

# Part 2: Deploying a Production-Grade Agentic MLOps System on AWS

## Part 1

This is part two; start here: [[part-1-designing-a-production-grade-agentic-mlops-system|Part 1: Designing a Production-Grade Agentic MLOps System]].

## Key Takeaways

This article is a pragmatic deployment playbook for moving a local Agentic MLOps stack to AWS using managed cloud services. The main operational pattern is:

- Keep the app architecture mostly unchanged, but shift model and observability layers to cloud-native services.
- Replace local LLM/embedding runtime dependencies (Ollama) with AWS Bedrock models.
- Run services in Kubernetes (EKS) with sensible resource limits and namespace/service isolation.
- Provision infra via Terraform as code for reproducibility.
- Use GitHub Actions to automate infra sync, image build/publish, and rollout.
- Track costs aggressively and tear down infrastructure when not actively used.

## External Resources

- [Part 1: Designing a Production-Grade Agentic MLOps System](https://kmeanskaran.substack.com/p/part-1-designing-an-agentic-mlops)
- [stock-agent-ops repo (aws-deployment branch)](https://github.com/karan842/stock-agent-ops/tree/aws-deployment)
- [complete ML system design README](https://github.com/karan842/stock-agent-ops/blob/master/doc/system_design.md)
- [AWS infra design README](https://github.com/karan842/stock-agent-ops/blob/aws-deployment/doc/AWS.md)
- [CI/CD workflow file](https://github.com/karan842/stock-agent-ops/blob/aws-deployment/.github/workflows/deploy.yml)
- [AWS Scripts directory](https://github.com/karan842/stock-agent-ops/tree/aws-deployment/scripts)
- [x.com/@kmeanskaran](http://x.com/@kmeanskaran)
- [Substack](http://kmeanskaran.substack.com)

## Original Content

> [!quote]- Source Material
> In [Part 1: Designing a Production-Grade Agentic MLOps System](https://kmeanskaran.substack.com/p/part-1-designing-an-agentic-mlops), we saw how to build Stock-Agent-Ops — an Agentic MLOps system that predicts the next 7 days (technically 5 trading days) of closing stock prices. It also generates sentiment analysis, line plots, and recent news related to the stock for financial reporting.
>
> Refer to [GitHub repo](https://github.com/karan842/stock-agent-ops/tree/aws-deployment), I moved AWS infra on aws-deployment branch.
> I recommend you read that article first to understand how we designed this system (me, ChatGPT, and AntiGravity) from scratch. Although both articles are kept at a high-level abstraction; otherwise, this would easily turn into a 200-page eBook.
>
> To learn more about the complete system design and deep AWS technical details, read the following README files:
> 
> - [A complete ML System Design](https://github.com/karan842/stock-agent-ops/blob/master/doc/system_design.md)
> - [AWS Infra Design](https://github.com/karan842/stock-agent-ops/blob/aws-deployment/doc/AWS.md)
>
> ![[part-2-deploying-a-production-grade-agentic-mlops-on-aws-01.jpeg]]
>
> In this article, we are not going to discuss what AWS is or explain its services. Instead, we will focus on how to connect the dots and deploy the system quickly with minimal setup.
>
> In the local version, I’ve been running the entire application using Docker Compose. Currently, I have three main Docker images:
>
> *ML + Agentic AI + classic microservice structure + caching + rate limiting*  
> *Streamlit UI for the financial dashboard*  
> *Streamlit dashboard for data drift detection, agent observability, and visual logs for the entire system*
>
> ![[part-2-deploying-a-production-grade-agentic-mlops-on-aws-02.png]]
>
> Apart from these, we also have other Docker images for supporting tools and services:
> 
> - Redis (for caching)
> - Qdrant (vector database)
> - Prometheus and Grafana (for overall system observability)
> I’ve used Docker Compose for the local setup to run everything together — you can refer to Part 1 for that. Additionally, I’ve used local Ollama models for LLM tasks and embeddings.
> Now, we need to prepare the application for AWS deployment. First, we must map everything from the code level to the infrastructure level. We will start by fixing the code-level components for AWS compatibility, and then move to infrastructure decisions like Docker and Kubernetes.
> This is a best practice to ensure seamless integration from local development to production. It’s not just about running Docker on the cloud and we must also adapt internal logic. For example, in our case, we currently rely on a local Ollama setup, which cannot remain the same in production.
> Let’s now look at each deployment step in detail.
>
> It is an easy step. Let me break it down:
> 
> - Create an AWS account (Free Tier — $100 credits if eligible)
> - Install AWS CLI
> - Configure an AWS IAM user and user group
> - Add the access keys to your local terminal
> You can simply copy-paste these steps into ChatGPT to get more precise, step-by-step instructions tailored to your system.
>
> In the Agentic AI part, we used Ollama models:
> 
> - LLM: gpt-oss:20b-cloud
> - Embedding model: nomic-text-embed
> This is exactly what I meant by moving from the code level to the infrastructure level. At the code level, we need to replace Ollama with AWS Bedrock.
>
> ![[part-2-deploying-a-production-grade-agentic-mlops-on-aws-03.png]]
>
> In this project, I’ve used:
> 
> - LLM: openai.gpt-oss-20b-1:0
> - Embedding model: amazon.titan-embed-text-v1
> Everything else at the code level remains the same. Only the model provider changes from a locally hosted Ollama setup to managed foundation models via AWS Bedrock.
> The k8s/ folder defines how our application runs inside EKS. This is where we convert our local Docker Compose setup into a production-ready Kubernetes environment.
>
> ![[part-2-deploying-a-production-grade-agentic-mlops-on-aws-04.png]]
>
> Everything runs inside a dedicated mlops namespace so the system stays isolated and organized. For sensitive data like API keys and AWS credentials, we use Kubernetes Secrets. In CI/CD, these are injected from GitHub Secrets, so nothing sensitive is hardcoded.
> Our main services, fastapi, frontend, and monitoring-app are deployed with defined CPU and memory limits to keep the cluster stable. We also configure basic health checks so Kubernetes can automatically restart any container that becomes unhealthy.
> For storage, we use persistent volumes backed by AWS EBS. This ensures that vector data in Qdrant and cached data in Redis remain safe even if pods restart.
> For observability, Prometheus collects metrics from the backend, and Grafana visualizes system performance and health.
> This structure keeps the system clean, stable, and production-ready without making it overly complex.
>
> We will push Docker images to AWS Elastic Container Registry (ECR), provision EC2 instances, and spin up an AWS Elastic Kubernetes Service (EKS) cluster with two worker nodes running on EC2.
> Don’t worry we’ll use Terraform to provision and configure everything in one go. No manual setup, no console clicking. One command, and the entire infrastructure comes to life.
> The terraform/ directory is the blueprint of our cloud environment. Instead of manually creating AWS resources, we define everything as code and let Terraform provision it in a repeatable and structured way.
> Terraform handles the core infrastructure: networking, the Kubernetes cluster, container registry, and identity management.
>
> ![[part-2-deploying-a-production-grade-agentic-mlops-on-aws-05.png]]
>
> In vpc.tf, we define the networking layer. Workloads run inside private subnets so they are not directly exposed to the internet. A NAT Gateway allows secure outbound communication (like pulling models or talking to AWS Bedrock), while an Application Load Balancer in public subnets manages inbound traffic safely.
> In eks.tf, we provision a managed EKS cluster (v1.29) with t3.xlarge node groups. The 16GB RAM is important for running the FastAPI backend with heavy ML libraries. Each node is configured with 50GB EBS storage to avoid disk pressure during large image pulls.
> In ecr.tf, we create private ECR repositories for each microservice to enable secure and fast image pulls within AWS.
> In iam.tf, we configure IRSA using an OIDC provider. Instead of injecting AWS keys into pods, services assume IAM roles directly with scoped permissions for resources like Bedrock and CloudWatch.
> Once defined, everything is controlled through Terraform commands:
> 1. terraform apply provisions or updates the full infrastructure.
> 2. terraform destroy removes it cleanly when needed.
> This makes the entire environment reproducible, manageable, and production-ready from the infrastructure layer itself.
>
> CI/CD (Continuous Integration and Continuous Deployment) ensures that every code change moves automatically from development to production without manual intervention.
> In this project, GitHub Actions handles the entire automation. The .github/workflows/deploy.yml file acts as the orchestrator for every update pushed to the repository.
>
> ![[part-2-deploying-a-production-grade-agentic-mlops-on-aws-06.png]]
>
> [Detail CI/CD structure](https://github.com/karan842/stock-agent-ops/blob/aws-deployment/.github/workflows/deploy.yml)
> Whenever new code is pushed, the pipeline starts by syncing infrastructure. It runs terraform apply to ensure any infrastructure changes such as updated variables or instance upgrades are reflected in AWS before deploying the new version.
> Next comes the Docker build stage. The images are built from the project root. This is critical because the backend needs access to modules from both the backend/ and src/ directories. Building from the root ensures imports work correctly and prevents runtime errors.
> Once built, the images are tagged with the specific Git SHA. This makes every deployment traceable to a commit. The images are then securely pushed to private ECR repositories.
> After pushing, the workflow dynamically updates the Kubernetes manifests. Using a simple sed replacement, repository placeholders in the YAML files are replaced with the actual AWS Account ID registry URL. This keeps the configuration environment-aware without hardcoding values.
> Finally, deployment happens using kubectl apply, followed by kubectl rollout restart. This ensures rolling updates, allowing the new version to be deployed without downtime.
> In simple terms, the CI/CD pipeline automates infrastructure synchronization, Docker image creation, registry updates, and Kubernetes rollout, turning every commit into a production-ready deployment.
>
> After executing the CI/CD pipeline, you can see all the Docker images running inside the Kubernetes cluster from the EKS dashboard.
> At this point, you just need to access the monitoring dashboard, frontend application, and Grafana dashboard to verify everything is working as expected.
>
> ![[part-2-deploying-a-production-grade-agentic-mlops-on-aws-07.png]]
>
> The complete application workflow and overall system design have already been covered in:
> 
> - [A complete ML System Design](https://github.com/karan842/stock-agent-ops/blob/master/doc/system_design.md)
> - [AWS Infra Design](https://github.com/karan842/stock-agent-ops/blob/aws-deployment/doc/AWS.md)
> Now the important thing is, the applications are running on an EKS cluster with 2 t3.xlarge nodes. This setup is powerful but it costs a lot. If you leave it running, the bill can increase very fast.
> Make sure to configure AWS Billing Alerts before testing anything. Set a budget limit so you get notified if usage crosses a threshold. Otherwise, the bill can skyrocket.
> After running and testing the application, monitor the pricing regularly and destroy all AWS resources to stop burning your wallet.
> After running all services on AWS we must destroy them before turning off your computer. So we will destroy all services, as our CI/CD is perfectly configured. So you can re-run the workflow to cold start entire system. We will use terraform to destory AWS services and recheck using AWS commands. I have written bash script to nuke AWS. [See this directory of bash scripts.](https://github.com/karan842/stock-agent-ops/tree/aws-deployment/scripts)
>
> - Always run your setup on a local machine before moving to AWS.
> - For faster, scalable, and accurate deployment, start from the code level and then move to infrastructure.
> - Always set a billing alert. I usually set it to $10 for PoC projects.
> - Spin up EKS with minimal nodes first. Don’t overprovision in the beginning.
> - Once your basic AWS setup works without errors, scaling becomes much easier.
> - A data drift admin dashboard is extremely important to monitor the ML model’s performance behind the scenes.
> - MLOps is not limited to the ML service. It also involves backend, infrastructure, monitoring, and deployment workflows.
> - Start using caching for ML inference to save both cost and response time.
> - Infra + ML Engineer will be a high-demand role very soon.
> - Terraform is one of the best tools you can use for building reliable Ops pipelines.
> - Always destroy AWS services when you are not using them.
> - Machine Learning is iterative. Don’t chase a perfect solution from day one.
> - Full-stack ML now means Data Engineering + ML + Backend + DevOps + Frontend + Cloud. AI can generate code, but it still struggles at infrastructure-level thinking.
>
> If you like this project and article then follow me on [X](http://x.com/@kmeanskaran) and subscribe to my [Substack newsletter](http://kmeanskaran.substack.com)
>
> ![[part-2-deploying-a-production-grade-agentic-mlops-on-aws-08.png]]
>
> Thanks for reading this blog and supporting this project. Up next, I’ll be sharing more about MLOps and how to set up Agents at scale.
> If you’d like to know more about me or need help solving ML + Ops problems, feel free to reach out. I’d be happy to contribute to your team.
> Here’s my website: [kmeanskaran.com](http://kmeanskaran.com)
>
> Signing off!
>
> No posts