---
created: 2025-03-17
description: A framework for automated extraction of procedural knowledge from GitHub repositories into standardized SKILL.md format, demonstrating 40% knowledge transfer gains from mined educational skills
source: https://arxiv.org/abs/2603.11808
type: paper
authors:
  - Shuzhen Bi
  - Mengsong Wu
  - Hao Hao
  - Keqian Li
  - Wentao Liu
  - Siyu Song
  - Hongbo Zhao
  - Aimin Zhou
arxiv: "2603.11808"
---

## Abstract

The transition from monolithic large language models (LLMs) to modular, skill-equipped agents represents a fundamental architectural shift in artificial intelligence deployment. While general-purpose models demonstrate remarkable breadth in declarative knowledge, their utility in autonomous workflows is frequently constrained by insufficient specialized procedural expertise. This report investigates a systematic framework for automated acquisition of high-quality agent skills through mining of open-source repositories on platforms such as GitHub. We focus on the extraction of visualization and educational capabilities from state-of-the-art systems including TheoremExplainAgent and Code2Video, both utilizing the Manim mathematical animation engine. The framework encompasses repository structural analysis, semantic skill identification through dense retrieval, and translation to the standardized SKILL.md format. We demonstrate that systematic extraction from agentic repositories, combined with rigorous security governance and multi-dimensional evaluation metrics, enables scalable acquisition of procedural knowledge that augments LLM capabilities without requiring model retraining. Our analysis reveals that agent-generated educational content can achieve 40% gains in knowledge transfer efficiency while maintaining pedagogical quality comparable to human-crafted tutorials.

## Key Takeaways

The paper formalizes an agentic skill as a four-tuple S = (C, pi, T, R) covering applicability conditions, policy (procedural knowledge), termination criteria, and a standardized interface. This maps cleanly onto the SKILL.md progressive disclosure architecture (metadata at startup, instructions on activation, resources on demand) that we already use in our own skill system. The formalism validates what [[repo-local skills and AGENTS.md turn recurring engineering work into repeatable agent workflows]] argues from a practitioner angle — skills need both the "what to do" and the "when to stop" clearly defined.

The extraction pipeline uses a two-stage ranking approach: dense bi-encoder retrieval to find candidate code modules matching task descriptions, followed by cross-encoder refinement with a relevance threshold. This is the same pattern used in RAG systems but applied to skill discovery across codebases. The filtering criteria (recurrence, verification, non-obviousness, generalizability) provide a useful checklist that [[agent skills need eval harnesses not vibe checks to ship reliably]] would benefit from incorporating.

A key finding is that 26.1% of community-distributed skills contained vulnerabilities including data exfiltration and privilege escalation. Their four-stage verification pipeline (static analysis, semantic classification, behavioral sandboxing, permission validation) is directly relevant to how we think about [[skill-creator now brings software testing rigor to agent skill authoring without requiring code]] — the security governance layer is arguably more important than the extraction itself.

The paper distinguishes Skills (procedural knowledge — "what to do") from MCP (tool connectivity — "how to connect") as orthogonal layers in the agentic stack. Skills provide domain intelligence while MCP provides system connectivity. This framing resolves confusion about whether [[LLMs can discover and reuse compositional tool skills via MCP primitives reducing token usage up to 80 percent]] competes with or complements the skill-file approach — they're complementary layers.

The SkillNet ontological framework for organizing large skill libraries (30% reduction in execution steps, 40% improvement in task rewards through skill composition) suggests that as skill counts grow, flat directory structures become insufficient. This connects to what [[EvoSkill discovers reusable agent skills through iterative failure analysis outperforming static prompts and transferring zero-shot]] demonstrates about skill evolution — discovery and organization need to co-evolve.

The case studies (TheoremExplainAgent and Code2Video) demonstrate that multi-agent architectures with Planner-Coder-Critic loops produce skills that transfer well. The Visual Anchor Prompting technique (overlaying a 10x10 grid on rendered frames for spatial reasoning) is a clever trick for VLM-based quality assessment that could be extracted as a standalone skill itself.

## External Resources

- [TheoremExplainAgent](https://github.com/TIGER-AI-Lab/TheoremExplainAgent) — Multi-agent system for generating long-form visual explanations of STEM theorems using Manim
- [Code2Video](https://github.com/showlab/Code2Video) — Code-centric framework for educational video generation with Planner-Coder-Critic architecture
- [repo2AI](https://github.com/huolter/repo2AI) — Tool for generating Markdown representations of repository structures for LLM consumption
- [Agent Skills Framework (arXiv)](https://arxiv.org/html/2602.12430v3) — Companion paper defining the broader agent skills paradigm
- [AlphaXiv Overview](https://www.alphaxiv.org/overview/2602.12430v3) — Overview and discussion of the agent skills framework

## Original Content

> [!quote]- Full Paper Text
> # Automating Skill Acquisition through Large-Scale Mining of Open-Source Agentic Repositories: A Framework for Multi-Agent Procedural Knowledge Extraction
>
> Shuzhen Bi, Mengsong Wu, Hao Hao, Keqian Li, Wentao Liu, Siyu Song, Hongbo Zhao, and Aimin Zhou
>
> East China Normal University, Shanghai Innovation Institute, University of Science and Technology of China
>
> #### Abstract
>
> The transition from monolithic large language models (LLMs) to modular, skill-equipped agents represents a fundamental architectural shift in artificial intelligence deployment. While general-purpose models demonstrate remarkable breadth in declarative knowledge, their utility in autonomous workflows is frequently constrained by insufficient specialized procedural expertise. This report investigates a systematic framework for automated acquisition of high-quality agent skills through mining of open-source repositories on platforms such as GitHub. We focus on the extraction of visualization and educational capabilities from state-of-the-art systems including TheoremExplainAgent and Code2Video, both utilizing the Manim mathematical animation engine. The framework encompasses repository structural analysis, semantic skill identification through dense retrieval, and translation to the standardized SKILL.md format. We demonstrate that systematic extraction from agentic repositories, combined with rigorous security governance and multi-dimensional evaluation metrics, enables scalable acquisition of procedural knowledge that augments LLM capabilities without requiring model retraining. Our analysis reveals that agent-generated educational content can achieve 40% gains in knowledge transfer efficiency while maintaining pedagogical quality comparable to human-crafted tutorials.
>
> ## 1 Introduction
>
> The deployment of artificial intelligence has undergone a paradigm shift from monolithic transformer-based large language models toward modular, skill-equipped agent architectures. While contemporary LLMs possess extensive declarative knowledge spanning diverse domains, their effectiveness in autonomous task execution remains limited by insufficient specialized procedural expertise required for real-world applications. This fundamental limitation has catalyzed the emergence of the "agent skill" paradigm—a modular abstraction framework wherein procedural knowledge is encapsulated into discrete, filesystem-based units that agents can dynamically discover, load, and execute on demand.
>
> By architecturally decoupling specific capabilities from underlying model parameters, this paradigm enables dynamic capability extension without incurring the prohibitive computational and temporal costs associated with model retraining or fine-tuning. The skill-based architecture transforms the fundamental question from "how do we train a model to perform task X?" to "how do we provide a model with executable procedural knowledge for task X?"
>
> Central to advancing this architectural vision is the challenge of skill acquisition at scale. Traditionally, high-quality skills are manually authored by domain experts, providing reliability guarantees but suffering from severe scalability constraints. Autonomous discovery methods, while promising, frequently struggle to maintain semantic coherence and pedagogical value in open-world environments.
>
> A third acquisition pathway involves systematic extraction of procedural knowledge from existing open-source software, particularly specialized agentic repositories hosted on platforms such as GitHub. These repositories often contain sophisticated, domain-specific logic for complex tasks—including mathematical theorem visualization, educational content synthesis, and multimodal explanation generation—that can be systematically refactored into standardized, reusable agentic skills.
>
> This report presents a comprehensive framework for automated skill acquisition through large-scale mining of GitHub-based agent repositories. We focus specifically on extraction of visualization and educational capabilities from two state-of-the-art systems: TheoremExplainAgent (TEA), which generates long-form visual explanations of STEM theorems, and Code2Video, which implements a code-centric paradigm for educational video generation. Our framework encompasses three primary components: (1) repository structural analysis and contextualization, (2) semantic skill identification through dense retrieval mechanisms, and (3) systematic translation to the SKILL.md standardized format.
>
> ## 2 The Formal Paradigm of Agentic Skills
>
> ### 2.1 Mathematical Formulation
>
> To establish rigorous foundations for skill extraction, we first define the mathematical structure of an agentic skill. Formally, an agentic skill S is represented as a four-tuple:
>
> S = (C, pi, T, R)
>
> where each component serves a distinct functional role in the skill's operational semantics. The applicability conditions C define the initiation set—the contextual prerequisites that determine when a skill becomes relevant for activation. This component enables efficient skill selection by allowing agents to maintain awareness of skill availability without loading complete procedural content into working memory.
>
> The policy pi encapsulates the core procedural knowledge, representing the sequence of actions or reasoning steps the agent must execute. This policy may manifest in multiple forms: natural language prompt templates, executable Python scripts, reinforcement learning policies, or hybrid symbolic-neural workflows. The policy component distinguishes skills from simple tool wrappers by embedding domain-specific reasoning and decision-making logic.
>
> Termination criteria T provide the logical conditions for determining successful skill completion, enabling both the executing agent and external orchestrators to verify goal achievement. These criteria may include output validation rules, state verification conditions, or success metrics specific to the task domain.
>
> The interface R establishes a standardized callable boundary, defining input parameters, output formats, and composition protocols that enable runtime integration with agent architectures. This standardization is critical for enabling skill reuse across heterogeneous agent implementations and facilitating hierarchical skill composition.
>
> This formal structure ensures that skills remain simultaneously executable, reusable, and governable, distinguishing them from atomic tools (which lack complex procedural logic) and episodic memories (which lack standardized callable interfaces).
>
> ### 2.2 The SKILL.md Specification
>
> The architectural implementation of the agent skill paradigm has converged on the SKILL.md specification, originally developed by Anthropic and subsequently released as an open standard. This specification implements a progressive disclosure architecture designed to minimize context window consumption while maintaining access to deep procedural knowledge.
>
> The progressive disclosure architecture organizes skill information into three hierarchical levels, each activated under different context-loading conditions:
>
> - Level 1 (Metadata): YAML frontmatter with name, description, version, trigger conditions. Pre-loaded at startup. 30-100 tokens.
> - Level 2 (Instructions): Procedural knowledge with workflows, best practices, step-by-step logic. Loaded upon activation. 200-5,000 tokens.
> - Level 3 (Resources): Auxiliary assets including executable scripts, reference documents, templates, schemas. Loaded on demand. Unbounded.
>
> Level 1 metadata serves as an efficient "table of contents," enabling agents to maintain awareness of thousands of available skills without context window degradation. When user requests match a skill's descriptive metadata, the agent activates Level 2, injecting procedural instructions into the conversation context as hidden meta-messages. This injection modifies the agent's internal reasoning process rather than its direct output, allowing skills to reshape problem-solving approaches.
>
> Level 3 resources remain dormant until explicitly invoked by Level 2 instructions or executable scripts, enabling skills to leverage arbitrarily large reference materials without impacting baseline context consumption.
>
> ## 3 Methodological Framework for Skill Extraction
>
> ### 3.1 Repository Structural Analysis and Contextualization
>
> Skill extraction begins with comprehensive structural decomposition of target repositories. Tools such as repo2AI generate Markdown-formatted representations of complete directory hierarchies and file contents. This structural mapping provides essential context for LLM-based extraction agents, enabling understanding of task orchestration patterns and logical dependencies.
>
> For repositories implementing complex agentic workflows, identification of central orchestration scripts (e.g., generate_video.py) and configuration directories (e.g., task_generator/prompts_raw) allows extraction processes to focus on reasoning logic and tool-use patterns that define specialized expertise. The structural analysis phase produces a hierarchical map of:
>
> - Core execution scripts and their input/output specifications
> - Configuration files defining workflow parameters and agent behaviors
> - Auxiliary modules implementing domain-specific algorithms
> - Documentation and usage examples demonstrating intended workflows
>
> ### 3.2 Semantic Skill Identification through Dense Retrieval
>
> Once repository structure is mapped, the system identifies "latent skills"—recurring procedural patterns amenable to generalization across contexts. This identification task is formulated as a two-stage ranking problem combining dense retrieval and cross-encoder refinement.
>
> #### 3.2.1 Dense Retrieval Stage
>
> The extraction agent encodes task descriptions and code modules into dense vector representations using trained bi-encoders. For a repository containing N code modules and a set of task descriptions, the bi-encoder produces embeddings. Candidate skills are identified by computing cosine similarity:
>
> sim(Ti, Mj) = (e_Ti · e_Mj) / (||e_Ti|| ||e_Mj||)
>
> The top-K candidate modules for each task are retained for subsequent refinement.
>
> #### 3.2.2 Binary Ranking Stage
>
> A cross-encoder ranker performs fine-grained relevance assessment by jointly encoding task-module pairs and producing relevance scores. Only modules exceeding a calibrated relevance threshold τ are promoted for skill extraction. This two-stage approach ensures that extracted skills represent genuinely reusable patterns rather than project-specific implementations.
>
> Extraction criteria include:
>
> 1. Recurrence: The procedural pattern appears in multiple contexts or solves a class of problems
> 2. Verification: The code is functional, well-documented, and free of critical bugs
> 3. Non-obviousness: The logic required domain expertise or debugging to discover
> 4. Generalizability: The pattern can be parameterized or adapted to different contexts
>
> ### 3.3 Translation to the SKILL.md Standard
>
> The final extraction stage synthesizes SKILL.md artifacts from identified procedural patterns. This translation process involves three primary components:
>
> #### 3.3.1 Frontmatter Generation
>
> The extraction agent synthesizes metadata conforming to YAML specifications: name, description, version, trigger, and dependencies.
>
> #### 3.3.2 Instruction Drafting
>
> Level 2 instructions are written as LLM-consumable procedural guidance rather than end-user documentation. Effective instructions emphasize step-by-step workflow decomposition with decision points, error handling strategies and common failure modes, best practices derived from repository analysis, and integration patterns with complementary skills or tools.
>
> #### 3.3.3 Asset Bundling
>
> Executable scripts, reference documentation, and configuration templates are organized into standardized subdirectories (scripts/, references/, templates/). Assets are refactored to eliminate hardcoded paths, API keys, or repository-specific dependencies, ensuring portability across deployment environments.
>
> ## 4 Deep Analysis of Source Repositories
>
> ### 4.1 TheoremExplainAgent: Multimodal STEM Explanation
>
> TheoremExplainAgent (TEA) addresses the challenge of communicating abstract STEM theorems through long-form video content exceeding five minutes in duration. The system implements a two-agent architecture comprising a Planner and a Coding Agent.
>
> The Planner functions as an instructional designer, transforming theorem statements into pedagogically structured storyboards. Key outputs include Scene Purpose, Scene Description, and Scene Layout.
>
> The Coding Agent translates storyboards into executable Manim Python scripts. TEA implements a multi-attempt error-correction loop enabling the agent to analyze Python stack traces and iteratively debug animation code. TEA integrates a Retrieval-Augmented Generation (RAG) system to ground the Coding Agent in current Manim documentation, preventing API hallucinations.
>
> ### 4.2 Code2Video: Code-Centric Educational Framework
>
> Code2Video implements a modular three-agent design: Planner (structures lecture content), Coder (converts storyboards to Python with scope-guided auto-fix), and Critic (uses VLMs to refine spatial layout).
>
> The Critic agent implements "Visual Anchor Prompting," a technique that converts continuous visual information into discrete grid references to facilitate spatial reasoning by VLMs. The process overlays a 10x10 grid on rendered frames, enabling precise identification of element positions and potential occlusions.
>
> Code2Video introduces TeachQuiz, a metric quantifying knowledge transfer effectiveness. Empirical results demonstrate that agent-generated videos achieve 40% gains in knowledge transfer efficiency compared to baseline code generation models.
>
> ## 5 Demonstrating Skill Acquisition
>
> ### 5.1 Skill 1: Visual Theorem Walkthrough
>
> Extracted procedural logic: (1) Generate scene plan defining coordinate layout, mathematical objects, and narrative script; (2) Implement temporal synchronization between visual transitions and narration using manim-voiceover; (3) Apply error-correction loop for Manim API compliance; (4) Validate scene coherence through storyboard-code consistency checks.
>
> ### 5.2 Skill 2: Visual Layout Critic
>
> Visual Anchor Prompting workflow: (1) Overlay 10x10 coordinate grid on screenshot; (2) Identify grid positions of primary visual elements; (3) Calculate pairwise spatial overlap; (4) If overlap exceeds threshold, generate positioning refactoring suggestions; (5) Apply suggestions and re-render.
>
> ## 6 Benchmarking and Evaluation Framework
>
> Multi-dimensional evaluation metrics: Safety (vulnerability rate via static analysis), Completeness (feature coverage via doc mapping), Executability (success rate via TEB/MMMC), Maintainability (schema drift via regression tests), and Pedagogy (TeachQuiz score).
>
> SkillNet structures skills within an ontological framework establishing relational connections such as "is-a-subset-of" and "requires-output-from." This enables 30% reduction in execution steps through skill composition and 40% improvement in average task rewards.
>
> ## 7 Security and Governance
>
> A comprehensive survey of community-distributed skills identified vulnerabilities in 26.1% of analyzed artifacts. The four-stage verification pipeline: G1 (static analysis for suspicious patterns), G2 (semantic classification for instruction-purpose alignment), G3 (behavioral sandboxing in isolated containers), G4 (permission validation against allowed-tools manifests).
>
> ## 8 The Future Agentic Stack
>
> The agent skills paradigm constitutes a critical layer distinguishing between procedural intelligence (Skills — "What to do", filesystem-based, durable) and system connectivity (MCP — "How to connect", session-based, runtime). This architectural orthogonality enables skills to provide domain intelligence for MCP tools.
>
> Evolution Agents will autonomously mine conversation logs and execution traces to refine existing skills, augmenting extracted skills with personalized adaptations.
>
> ## 9 FAQ
>
> - Skill extraction separates procedural knowledge from model parameters, reducing computational costs by 2-3 orders of magnitude vs fine-tuning
> - SKILL.md is provider-agnostic, interpretable by any sufficiently capable LLM
> - Progressive disclosure enables awareness of 10,000+ skills while only loading activated instructions
>
> ## 10 Conclusion
>
> Systematic extraction of procedural knowledge from GitHub's open-source agentic repositories enables scalable acquisition of high-quality agent skills. The future lies not in ever-larger monolithic models but in composable, governable, and continuously evolving skill ecosystems.
>
> [Source: arXiv:2603.11808](https://arxiv.org/pdf/2603.11808)
