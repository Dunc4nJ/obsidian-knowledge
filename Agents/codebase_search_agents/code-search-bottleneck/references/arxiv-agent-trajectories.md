Title: Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories

URL Source: https://arxiv.org/html/2511.00197

Markdown Content:
(2026)

###### Abstract.

The increasing deployment of Large Language Model (LLM) agents for complex software engineering tasks has created a need to understand their problem-solving behaviours beyond simple success metrics. While these agents demonstrate impressive capabilities in automated issue resolution, their decision-making processes remain largely opaque. This paper presents an empirical study of agent trajectories, namely the execution traces capturing the steps agents take when attempting to resolve software issues. We analyse trajectories from three state-of-the-art code agents (OpenHands, SWE-agent, and Prometheus) on the SWE-Bench benchmark, examining both successful and failed attempts. Our investigation reveals several key insights into agent behaviour. First, we identify how distinct problem-solving strategies, such as defensive programming and context gathering, enable success in different scenarios. Second, we find that failed trajectories are consistently longer and exhibit higher variance than successful ones, with failure patterns differing significantly between agents. Third, our fault localisation analysis shows that while most trajectories correctly identify problematic files (72-81% even in failures), success depends more on achieving approximate rather than exact code modifications. These and other findings unveiled by our study, provide a foundation for understanding agent behaviour through trajectory analysis, contributing to the development of more robust and interpretable autonomous software engineering systems.

Code Agents, Large Language Model, Trajectories Analysis

††copyright: acmlicensed††journalyear: 2026††doi: XXXXXXX.XXXXXXX††conference: 48th International Conference on Software Engineering; April 2026; Rio de Janeiro, Brazil††isbn: 978-1-4503-XXXX-X/2018/06††ccs: Software and its engineering Automatic programming††copyright: none
1. Introduction
---------------

Large Language Models (LLMs) have rapidly advanced from simple code completion to complex repository-level problem solving (Ye et al., [2022](https://arxiv.org/html/2511.00197v1#bib.bib29), [2023](https://arxiv.org/html/2511.00197v1#bib.bib28); Chen et al., [2025b](https://arxiv.org/html/2511.00197v1#bib.bib8); Wang et al., [2025a](https://arxiv.org/html/2511.00197v1#bib.bib23); Yang et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib27); Zhang et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib32); Xia et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib26); Bouzenia et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib3)). This shift has driven the emergence of code agents—systems that combine LLMs with scaffolding, external tools, and reasoning loops to autonomously resolve software engineering tasks. Benchmarks such as SWE-Bench (Chowdhury et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib9)) demonstrate that these agents can fix real-world GitHub issues, suggesting significant potential for automating software maintenance at scale. Despite their impressive capabilities, current evaluations treat agents as black boxes, focusing primarily on success rates while overlooking the rich information contained in their execution trajectories (Bouzenia and Pradel, [2025](https://arxiv.org/html/2511.00197v1#bib.bib4); Wang et al., [2025b](https://arxiv.org/html/2511.00197v1#bib.bib24)).

The opacity of agent systems presents a challenge for practitioners and researchers for improving these systems. As they rely largely on experimental trial-and-error to improve these systems, it remains unclear whether failures stem from insufficient context, flawed reasoning, poor fault localization, or other factors. Trajectories, or the detailed logs of every step an agent takes during problem solving, offer an unexplored window into agent behaviour. A few studies(Kim et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib12); Song et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib20); Lin et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib15)) have identified the potential of trajectories to agent performance, such as through contrastive learning, while other work(Bouzenia and Pradel, [2025](https://arxiv.org/html/2511.00197v1#bib.bib4); Ceka et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib6); Chen et al., [2025a](https://arxiv.org/html/2511.00197v1#bib.bib7)) focuses on high level patterns and decomposing trajectory structure. However, they do not take advantage of trajectories to gain a detailed understanding of how agents approach tasks, where they struggle, and why they fail, beyond what they achieve.

Our study addresses this gap. We conduct the first comparative analysis of agent trajectories on the SWE-Bench benchmark, using three diverse systems: OpenHands (Wang et al., [2025a](https://arxiv.org/html/2511.00197v1#bib.bib23)), SWE-agent (Yang et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib27)), and Prometheus (Chen et al., [2025b](https://arxiv.org/html/2511.00197v1#bib.bib8)). Our investigation moves beyond binary success metrics to examine the pathways agents follow, comparing successful and failed attempts to identify critical factors that determine outcomes.

We investigate three research questions that progressively deepen our understanding of agent behaviour. First, we examine the unique capabilities of different agents by analysing issues that only specific agents can resolve, conducting deep dives into the trajectories to reveal problem-solving strategies. Second, we quantify the structural differences between successful and failed trajectories, uncovering patterns in trajectory length and variance that correlate with failure modes. Third, we investigate fault localisation capabilities at multiple granularities, assessing how precisely agents identify problematic code and how this precision relates to ultimate success.

By moving beyond binary success rates, this study offers a foundation for interpreting and improving code agents through trajectory-level understanding. We argue that robustness and interpretability—rather than raw leaderboard scores—are the key challenges in building the next-generation of autonomous software engineering systems.

In summary, our work makes the following contributions:

*   •Trajectory dataset construction: We assemble and normalise execution traces from three state-of-the-art code agents on SWE-Bench Lite and Verified. 
*   •Comparative trajectory analysis: We provide the first detailed comparative qualitative study of trajectories across multiple state-of-the-art agents, revealing how successful problem-solving strategies as well as failure modes vary between systems. 
*   •Structural characterisation of failures: We quantify differences in trajectory lengths, showing systematic patterns between success and failure. 
*   •Empirical study of fault localisation We provide the first cross-agent analysis of localisation accuracy at file, function, and hunk levels. 
*   •Takeaways on agent behaviour: We identify eight takeaways on agent behaviour, unveiling learnings on trajectory length, strategies, success and failure patterns, and fault localisation ability. 

2. Related Work
---------------

### 2.1. Code Agents

The challenge of complex, multi-step problems has led to the development of _code agents_ that move beyond stand-alone LLMs (Wang et al., [2024b](https://arxiv.org/html/2511.00197v1#bib.bib21); Ye et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib31); Ye and Monperrus, [2024](https://arxiv.org/html/2511.00197v1#bib.bib30); He et al., [2023](https://arxiv.org/html/2511.00197v1#bib.bib10); Luo et al., [[n. d.]](https://arxiv.org/html/2511.00197v1#bib.bib16)). An agent is a system composed of one or more core LLMs enhanced by a scaffolding of abstracts and tooling (Anthropic, [2024](https://arxiv.org/html/2511.00197v1#bib.bib2)). This architecture enables an agent to perform complex reasoning (Wei et al., [2022](https://arxiv.org/html/2511.00197v1#bib.bib25)), execute actions (Wang et al., [2024a](https://arxiv.org/html/2511.00197v1#bib.bib22)), understand their outcomes, and plan its next activity (Huang et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib11)). They are therefore significantly more capable at problems requiring deeper understanding and multiple steps. Notable academic examples of software engineering agents include SWE-agent (Yang et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib27)), AutoCodeRover (Zhang et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib32)), OpenHands (Wang et al., [2025a](https://arxiv.org/html/2511.00197v1#bib.bib23)), RepairAgent (Bouzenia et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib3)) and Prometheus (Chen et al., [2025b](https://arxiv.org/html/2511.00197v1#bib.bib8)), as well as the comparable Agentless approach (Xia et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib26)).

Agentic systems, with their diverse architectures combining different LLMs, frameworks, and reasoning strategies, are largely treated as opaque systems (Martinez and Franch, [2025](https://arxiv.org/html/2511.00197v1#bib.bib17)). The lack of systematic ablative studies and the inherent randomness of their core LLMs hinder our understanding of why they succeed or fail. Motivated by this gap, our work aims to systematically investigate agent behaviour to inform more robust and effective designs.

### 2.2. Agent Trajectory Studies

Agent trajectories have proven useful for improving agent performance, such as using them in contrastive learning, fine-tuning or iterative optimisation (Kim et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib12); Song et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib20); Lin et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib15)). However, the value of using them for understanding agents has been overlooked, despite usage in industry (LangChain, [2025](https://arxiv.org/html/2511.00197v1#bib.bib14); Meng et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib18)). To our knowledge, there are five works that look at this potential.

A quantitative study of top-performing agents on SWE-bench by [Chen et al.](https://arxiv.org/html/2511.00197v1#bib.bib7) revealed that Python execution errors during a task are a primary challenge, corresponding to increased reasoning overhead and lower success rates (Chen et al., [2025a](https://arxiv.org/html/2511.00197v1#bib.bib7)). Another study of execution traces by [Ceka et al.](https://arxiv.org/html/2511.00197v1#bib.bib6) highlights that fault reproduction is a weak link and finds that agent-generated patches are typically more minimal, localised, and less context-aware than human-written ones, especially for more difficult problems (Ceka et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib6)), however, this study focuses more on the patch produced rather than the process. It has also been found that as agentic systems grow in complexity, new failure modes related to coordination and alignment overhead emerge (Pan et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib19)). Addressing the complexity of these execution trajectories, SeaView (Bula et al., [2025](https://arxiv.org/html/2511.00197v1#bib.bib5)) provides a tool for visually inspecting them to aid in the analysis. Finally, [Bouzenia and Pradel](https://arxiv.org/html/2511.00197v1#bib.bib4) created a taxonomy and framework for trajectory patterns to achieve a high-level understanding, using RepairAgent, AutoCodeRover, and OpenHands as subjects (Bouzenia and Pradel, [2025](https://arxiv.org/html/2511.00197v1#bib.bib4)).

While crucial for defining overarching patterns, current studies lack a fine-grained, bottom-up analysis of agent behaviour, particularly missing insights on partial progress that can be found by examining failing trajectories. Our work addresses this gap with a detailed comparative empirical study of code agent trajectories.

3. Empirical Study Design
-------------------------

We design our empirical study in three parts, starting with case studies of uniquely solved issues, followed by computing and comparing trajectory lengths and fault localisation ability.

### 3.1. Data Collection

To understand the trajectories from multiple code agents, our work considers three code agents selected based on the criteria that they must: 1) be open source, 2) have trajectories available, and 3) be released within the past year and currently maintained.

We choose OpenHands (Wang et al., [2025a](https://arxiv.org/html/2511.00197v1#bib.bib23)) and SWE-agent (Yang et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib27)) as they represent established state-of-the-art baselines in autonomous software engineering research, and Prometheus (Chen et al., [2025b](https://arxiv.org/html/2511.00197v1#bib.bib8)) as a novel methodology specialised in codebase-level understanding. We used their results on both SWE-bench Lite and Verified (Chowdhury et al., [2024](https://arxiv.org/html/2511.00197v1#bib.bib9)). The trajectories for OpenHands and SWE-agent are collected from a public bucket made available by the SWE-Bench benchmark maintainers (LangChain, [2024](https://arxiv.org/html/2511.00197v1#bib.bib13)). Prometheus logs are collected directly from the experimental evaluation. The details of each agent are summarised in Table [1](https://arxiv.org/html/2511.00197v1#S3.T1 "Table 1 ‣ 3.1. Data Collection ‣ 3. Empirical Study Design ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories").

Table 1. Selected Code Agents on Two SWE-bench Datasets

### 3.2. Research Questions

RQ1: What bugs can the three agents uniquely resolve?: We identify all those bugs that each agent is able to solve uniquely. We then conduct deep dives into samples from each of these unique sets, dividing the trajectory events into five categories for consistent comparison between trajectories.

RQ2: How different are the failing and successful trajectories?: We measure this by the number of steps in the trajectory, comparing the findings between successful and failed trajectories.

RQ3: To what extent do code agents succeed in locating faults before producing the patch?: We calculate how precisely the agent’s patches match the gold patch for the issue, so as to explore the agent’s ability to understand the repository structure, progress in solving the issue, and localise the fault.

### 3.3. Methodology for RQ1

The SWE-Bench experiments public repository contains information on which issues were successfully resolved in each submission. This data is extracted for each of the agents studied to compute the following evaluation metrics.

The uniqueness of each agent’s contribution is defined as the set of issues resolved exclusively by that agent. This is calculated using the set difference between an agent’s set of resolved issues and the union of the other agents’ sets. We do this for each agent studied.

After obtaining the unique issue sets for the three agents, we conduct a manual inspection of the trajectories in these sets to understand what enables one agent to succeed compared to the other two. Three trajectories are uniformly selected from each of the three unique sets as a representative sample and examined. As agent trajectories are long and complex, a structured analysis framework is developed to extract the main decision points. Each trajectory is segmented into five distinct phases of the problem-solving process:

1.   (1)Diagnosis: Initial identification of relevant files, classes, and functions. 
2.   (2)Problem Reproduction: Attempt to trigger the bug and observe the reported behaviour. 
3.   (3)Hypothesis and Plan: Articulated reasoning for a potential fix. 
4.   (4)Implementation: The first significant code modification made. 
5.   (5)Verification: Process of testing the solution to confirm the fix. 

In the case where the agent used multiple attempts to solve the issue, such as using newly learned information to change the plan, the trajectory was considered as a loop with the same five steps, with the verification step leading to a success which ends the attempt or a failure which triggers a new loop. We focus especially on hypothesis and implementation and look for points where failed approaches diverge from successful ones.

This framework enables a consistent comparison across trajectories and can be used to determine divergence points in agent behaviour.

### 3.4. Methodology for RQ2

We hypothesise that failed attempts contain more iterations than successful ones, as the agent likely gets stuck and goes down unsuccessful paths during the reasoning process. We compute the number of steps in each trajectory and then derive the statistical distribution of this value in failed and successful trajectories.

Taking inspiration from the thought-action-result structure proposed by [Bouzenia and Pradel](https://arxiv.org/html/2511.00197v1#bib.bib4)(Bouzenia and Pradel, [2025](https://arxiv.org/html/2511.00197v1#bib.bib4)), we define a step as an event in the trajectory that is one of these three categories. Their work calculates length in terms of iterations, which is such a sequence of thought, action, and result events. We instead opt to count these steps individually, so as to preserve granularity and potential for more detailed study and avoid making direct associations between adjacent events in the case they are not actually related.

A Thought Step indicates the agent printing its reasoning or reflection. An Action Step can be any of tool calls, commands, or action-oriented interaction between the internal components, such as making a call to knowledge graph or communication between agents in a multi-agent system. A Result Step is an event containing the output or consequence of an Action.

A trajectory is thus an array of Steps of one of these types. We implement parsers for each of the agents to convert the trajectory data into this unified format. Table [2](https://arxiv.org/html/2511.00197v1#S3.T2 "Table 2 ‣ 3.4. Methodology for RQ2 ‣ 3. Empirical Study Design ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories") describes how steps are extracted from each agent to give a unified interface over disparate agent output formats.

Table 2. Summary of Trajectory Parser Implementations for Different Agent Artifacts

### 3.5. Methodology for RQ3

RQ3 explores the ability of the agents to accurately localise the fault and to what level of detail they succeed, beyond the final success and failure outcomes. We derive three levels of fault localisation measure how much progress the agent makes in identifying the location of the problematic code: correct file, correct function, and correct hunk or lines. This value can be correlated with the outcome. For every issue, we compare the agent’s candidate patch and the gold patch available in the benchmark dataset. We extract the modified files, modified functions, and modified hunks from each, and check whether all the entities in the gold patch are present in the candidate patch. Additionally, we implement a “lenient” hunk match check, which allows line differences within a hunk up to a tolerance of 5, represented as a partial match using the value 0.5. Note that this check still requires all hunks themselves to be present, and only allows for deviations in line numbers within that hunk, so missing hunks would lead to an outcome of 0. Thus, each patch pair has a result object defined by the format in Table [3](https://arxiv.org/html/2511.00197v1#S3.T3 "Table 3 ‣ 3.5. Methodology for RQ3 ‣ 3. Empirical Study Design ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories").

Table 3. Fault Localisation Result Format

These results are then tallied to understand trends across the complete dataset in two ways:

*   •Marginal frequencies: We count number of successes and failures for each metric individually. 
*   •Joint frequencies: We compute the frequency of each unique combination of metric outcomes. 

We expect to see a funnel-like pattern, as increasingly fewer patches are able to accurately locate the fault as the granularity increases.

We note that the relation between a perfect fault localisation as per this criteria and successful outcome is not trivial, as success on the benchmark is based on whether the patch passed all test cases. The presence of additional modifications in the candidate patch is ignored, as this question only seeks to know whether the agent could correctly identify where the fault was, even though it is possible that extra changes cause the overall solution to fail. Conversely, it is likely that many successful trajectories do not modify the same hunks as the gold patch, instead finding a different solution that still works. Thus, the gold patch should be considered a guide for comparison rather than an arbiter of success, but we occasionally refer to it as ”correct” for simplicity.

4. Empirical Study Results
--------------------------

### 4.1. RQ1: Uniquely Repaired Issues

![Image 1: Refer to caption](https://arxiv.org/html/2511.00197v1/lite_venn.png)

(a) Lite

![Image 2: Refer to caption](https://arxiv.org/html/2511.00197v1/verified_venn.png)

(b) Verified

Figure 1. Resolved issues in SWE-Bench.

Figures [1](https://arxiv.org/html/2511.00197v1#S4.F1 "Figure 1 ‣ 4.1. RQ1: Uniquely Repaired Issues ‣ 4. Empirical Study Results ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories") illustrate the unique issues that each agent was able to solve in SWE-Bench Lite and Verified, respectively. We present three case studies, each diving into one issue from each of the unique sets of three agents, chosen uniformly at random.

#### 4.1.1. Prometheus uniqueness

Prometheus could solve 7 unique issues from SWE-Bench Lite and 8 in Verified. This limited improvement contrasts with the larger gains achieved by the other two agents on Verified.

Case study: django-11964. The issue description states that unexpected types are returned when creating Django model instances with TextChoices or IntegerChoices fields.

Prometheus first conducted an analysis of the issue and identified that the problem was fundamentally about enum representation rather than database field behaviour. It arrived at a solution that overrode the  __str__  method in both IntegerChoices and TextChoices classes, and modified IntegerField.to_python() to handle enum instances. This approach was minimal and leveraged Django’s existing patterns. The final patch addressed both the enum behavior and field conversion aspects of the problem.

SweAgent correctly reproduced the bug, but then went down a complex path of metaclass modification, attempting to change how enum values are stored during class creation rather than simply overriding instance method behaviour.

OpenHands also reproduced the bug but misidentified the problem scope. It could not recognise this as an enum representation issue, instead creating a new descriptor method for the enum class database and field level, trying to modify ORM query behaviour and field validation logic. This led to increasingly complex, misguided solution attempts that never addressed the actual root cause.

SweAgent and OpenHands trajectories display a misunderstanding of the problem domain, whereas Prometheus displayed an understanding of the typical way of working in the Django repository.

#### 4.1.2. OpenHands uniqueness

OpenHands could solve 11 unique issues in SWE-Bench Lite and 17 issues in Verified.

Case study: pylint-6258. The issue description states that the ignore flags were not being respected when Pylint was run in recursive mode.

OpenHands formed the hypothesis that the _discover_files method in pylinter.py was responsible for finding files when the –recursive=y flag was used, reasoning that this method traversed the file system and collected Python files before any ignore patterns were applied. The ignore logic was being executed too late, after the file list had already been discovered. It applied one large code change, which changed the relevant method from static to instance, so that linter instance’s configuration could be accessed. Compared to the gold patch, the OpenHands patch achieved the right functionality, but was less efficient as it traverses directories to check for ignored files even when the root should be ignored. The gold patch additionally reveals that the same logic existed in a different function, and extracts it into a helper to avoid duplication.

SWE-Agent successfully reproduced the bug and performed the right reasoning about the problem at hand. However, its first code modification resulted in all files being ignored, which was a regression. The main point of deviation was its failure to convert _discover_files to an instance method. As a result, SWE-Agent spent time debugging and creating new test cases, and could not access the config.

Prometheus failed to reproduce the bug as its attempts hit the recursion limit. It was nevertheless able to formulate a hypothesis using static analysis, correctly identifying that filtering logic was being applied too late, and showed a plan to modify the function to accept ignore configurations. However, it then engaged in extensive context gathering as it tried to figure out how configuration options worked in the program, hitting another limit before finding a result, and thus failing to implement a patch.

Table 4. Number of Steps in Successful and Failed Trajectories

#### 4.1.3. SWE-agent uniqueness

SWE-agent solved 46 and 71 unique issues in SWE-Bench Lite and SWE-Bench Verified, respectively.

Case study: sympy-12236. The issue description states that a division of polynomials returned the wrong answer due to incorrectly simplifying the given expression.

SWE-Agent looked for the apart function and reproduced the issue using a test case. The agent’s hypothesis was that the function was using integer division instead of field division during polynomial division and thus planned to modify the division logic. The patch added a check during the simplified integer-based calculation, comparing the simplified value to the original and retaining the original field type if they were not mathematically identical. This is a different approach from the gold patch, which targets a specific utility function to convert fractions to polynomial and adds a more robust case. The SWE-Agent patch displays less mathematical knowledge, but still achieves the desired fix using a more defensive programming approach.

Prometheus reproduced the error but did not start with the right hypothesis, instead focusing on symbolic values and modifying the logic around symbol handling in the n the apart function in sympy/polys/partfrac.py. Verifying this change led to recursion and recursion errors, which the agent attempted to fix using additional logic. It was not able to re-evaluate its hypothesis even though it entered multiple loops to reason about the error.

The reasoning of OpenHands was similar, reproducing the issue but identifying the problem to be with symbolic values in the apart function. Like Prometheus, its attempted fixes led to other, increasingly unrelated error messages that it tried to patch with extra code. The agent generated a patch and ran test cases that produced the expected output, however, this patch was incorrect as it failed the unit test for the div method. Thus, the root cause of the issue was missed.

### 4.2. RQ2: Length of Successful and Failing Trajectories

Table [4](https://arxiv.org/html/2511.00197v1#S4.T4 "Table 4 ‣ 4.1.2. OpenHands uniqueness ‣ 4.1. RQ1: Uniquely Repaired Issues ‣ 4. Empirical Study Results ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories") presents a statistical comparison of trajectory lengths for both benchmarks and all agents. We consider the overall step count, including all step types. Across all configurations, failed trajectories are longer on average and have a wider distribution than successful ones. However, this discrepancy varies between agents as well as between benchmarks.

##### Agent profiles

In absolute terms, both OpenHands and SWE-agent exhibit around 20 more steps in failures in SWE-Bench Lite, while Prometheus takes 49 more. In verified, the difference is greater, with OpenHands having 44 more steps on average, SWE-agent having 22 more, and Prometheus having 74 more. However, as the agents have differing levels of verbosity, it is useful to compute the increase in trajectory length for failures as a percentage of the successful length. SWE-agent failed trajectories are 12.6% longer in SWE-Bench Lite and 18.5% longer in SWE-Bench Verified, while OpenHands failed trajectories are 31.0% longer and 82.5% longer in the respective benchmarks. Prometheus lies in the middle with its failed trajectories being 56.6% longer in Lite and 50.7% longer in Verified, both representing a significant divergence on par with OpenHands in Lite. As SWE-agent trajectories are always longer, usually around two to three times as many steps as OpenHands, there may be inverse correlation between the average successful trajectory length and the severity of failure. This suggests that a more granular, incremental problem solving strategy involving many small steps requires more steps to achieve a successful outcome, but wrong steps are less catastrophic.

SWE-Agent also has the most modest difference in standard deviation between success and failure, where the latter is only marginally higher. In contrast, the range of values for failure in OpenHands is much greater, with a standard deviation of 60.63 versus 46.60 in Lite, and for Verified the value for failures is double that of successes. Prometheus exhibits the most extreme variation in this metric; its standard deviation for failures is nearly three times that of its successes in Lite (100.79 versus 34.62) and remains drastically higher in Verified. We can thus infer that two kinds of failures are encountered, the first clustered around the median, which fail relatively quickly, and a second kind that continues for a long number of steps and behaves unpredictably.

Figures [2](https://arxiv.org/html/2511.00197v1#S4.F2 "Figure 2 ‣ Agent profiles ‣ 4.2. RQ2: Length of Successful and Failing Trajectories ‣ 4. Empirical Study Results ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories") and [3](https://arxiv.org/html/2511.00197v1#S4.F3 "Figure 3 ‣ Agent profiles ‣ 4.2. RQ2: Length of Successful and Failing Trajectories ‣ 4. Empirical Study Results ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories") visualise the diverse and more drastic failures of OpenHands and Prometheus. OpenHands and Prometheus failures are longer tailed, with OpenHands having the same maximum length for failures and successes, and Prometheus having even longer failures. SWE-Agent fails faster, which is desirable for performance, resource efficiency, and learning ability.

![Image 3: Refer to caption](https://arxiv.org/html/2511.00197v1/violin_lite.png)

Figure 2. Trajectory Step Counts in SWE-Bench Lite

![Image 4: Refer to caption](https://arxiv.org/html/2511.00197v1/violin_verified.png)

Figure 3. Trajectory Step Counts in SWE-Bench Verified

### 4.3. RQ3: Fault Localisation in Successful and Failing Trajectories

Table 5. Fault localisation (FL) Performance by File, Function, and Hunk Level

*   •Legend: Percentage (Count). Percentages are calculated per outcome. 0 = No Match; 1 = Match; 0.5 = Close Match within 5 lines (Hunk level only). 

Table [5](https://arxiv.org/html/2511.00197v1#S4.T5 "Table 5 ‣ 4.3. RQ3: Fault Localisation in Successful and Failing Trajectories ‣ 4. Empirical Study Results ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories") displays the percentage and number of trajectories that achieved each of the three levels of fault localisation (FL), meaning that they modified the same files, functions, or hunks as the gold patch for a given issue. We compare success and failure outcomes in every configuration.

Successful outcomes unsurprisingly have a high frequency of file level matches across the board, with over 90% targeting the same files as present in the gold patch. This number drastically drops at the function level, with only about 27% of successful patches modifying the same function as the gold patch. SWE-agent’s successful attempts in SWE-Bench Lite are slightly better than the others at targeting the gold functions with a value of 33.5%. This means that file level localisation is necessary but not sufficient; successful patches almost always need to find the right file, but not necessarily the exact function, implying that agents can still succeed with approximate edits. Correct fixes could potentially be made at various parts of the file, for instance by creating a new function or modifying a wrapper or child method of the gold function. Similarly, only a handful of successful patches targeted the exact hunks as the gold patches, but around 9-11% of patches were within five lines.

![Image 5: Refer to caption](https://arxiv.org/html/2511.00197v1/faultloc_comb.png)

Figure 4. Proportion of Fault Localisation Combination Outcomes

Failed outcomes also have a high frequency of file level matches, reaching as high as 81% in the case of SWE-agent on SWE-Bench Lite. This highlights that the majority of trajectories that fail are still able to locate the problematic file, meaning that problems in fault localisation happen at a deeper level. Failed patches perform notably worse on SWE-Bench Verified, with 62.7% and 59.3% of patches targeting the gold file, compared to 79.8% and 81.4% in Lite. The file level again sees a drop in performance. The only outlier is OpenHands in SWE-Bench Lite, which achieves similar levels of function localisation for successful and failed patches, at around 27%. In all other cases, failed patches are worse at targeting the gold functions than their successful counterparts, especially in Verified, where all three agents’ failed attempts are only half as good. Notably, at the hunk level on the Lite benchmark, the performance of OpenHands’ failed trajectories in producing close matches (10.4%) is on par with that of all other successful ones (9.6%–12.5%). This pattern, observed at both the function and hunk level, indicates that partial progress towards a solution is not indicative of success for OpenHands on the issues in the Lite benchmark.

The frequencies of unique combinations of fault localisation outcomes at the file, function, and hunk levels are illustrated in Figure [4](https://arxiv.org/html/2511.00197v1#S4.F4 "Figure 4 ‣ 4.3. RQ3: Fault Localisation in Successful and Failing Trajectories ‣ 4. Empirical Study Results ‣ Understanding Code Agent Behaviour: An Empirical Study of Success and Failure Trajectories"). In all instances, the most frequent combination is file match, function miss, hunk miss, indicated as the largest component of each stacked bar, reinforcing the idea that trajectories are generally able to find the correct file, and spent most of their efforts exploring within the file. A complete failure pattern (file miss, function miss, hunk miss) seen at the top of every bar, is predominantly observed by failing trajectories and is more common in the Verified partition. At the file level, 35% to 40% of failed trajectories in Verified fail to locate the file, whereas only 20% to 25% of them fail in Lite. Recalling the findings from RQ2, where all agents had similar failing trajectory lengths in Verified and Lite, localising the wrong file does not correspond to a faster failure. This reveals that agents spend an equivalent amount of time exploring wrong and correct file paths in failed cases in SWE-Bench Verified. The small number of successful trajectories in this category indicates that solving bugs through code changes in another file is possible but unlikely.

### 4.4. Discussion

Prometheus’ detailed context retrieval seems to help it solve complex issues, but sometimes causes it to get stuck in the search. Its failures were often due to reaching recursion limits, which we know to be high based on the trajectory lengths from RQ2. A direction for improvement can be thus to focus on abandoning paths and backtracking earlier.

Although most SWE-Bench leaderboard submissions perform better on Verified than the other partitions, as the issues have been verified for solvability, RQ2 and RQ3 uncover surprising failure patterns. In RQ2, OpenHands and Prometheus trajectory length distributions dramatically vary in Verified compared to Lite; successes are more tightly clustered whereas failures are more widely spread out and unpredictable. SWE-agent is not affected by these changes. In RQ3, Verified contains a higher proportion of patches generated that failed to even find the correct file. These findings hint at the possibility that a higher clarity of tasks to solve may expose weaknesses in some agents’ architecture that get hidden in the noisier Lite dataset. A more comprehensive inspection of results across both partitions, incorporating agent architectural features, is crucial to explore this possibility.

Analysis of fault localisation reveals distinct areas for improving performance. For all agents, localising a fault at the hunk level, even within five lines of the gold patch, is a predictor of success. On SWE-Bench Verified, there remains significant room for improvement in file-level localisation, which is a bottleneck for a successful outcome. In contrast, on SWE-Bench Lite, where file localisation is already high (at least 72% even for failed trajectories), there are only marginal gains from further improving this metric. In all cases, even successful trajectories rarely achieve a perfect line-level match, suggesting that aiming for a flawless match is an unproductive goal. Instead, enhancing the agent’s capacity for close proximity hunk localisation represents a promising avenue for future development. Additionally, Finding 8 posits a potential avenue to achieve faster failures by detecting and abandoning unproductive trajectories, such as earlier detection of an incorrect file.

5. Threats to Validity
----------------------

The case studies in RQ1 cover only a small subset of trajectories, which may limit generalisability. We use uniform sampling to reduce bias, but the size of the sample may miss some behavioural diversity. To balance this, we combine in-depth qualitative analysis with large-scale quantitative results from RQ2 and RQ3. The extraction of thought, action, and result steps may be subjective. Extending to other agents requires consistent parsing across formats. To mitigate this, we focus only on repository exploration and code modification events, excluding implementation-specific ones, and make cross-agent comparisons mainly in relative terms.

6. Conclusion
-------------

Our study advances the understanding of autonomous software engineering by moving beyond binary success metrics and introducing trajectory analysis as a key lens for evaluating code agents. Through a comparative study of OpenHands, SWE-agent, and Prometheus on the SWE-Bench benchmark, we reveal that agent trajectories encapsulate behavioural insights often obscured by outcome-only evaluation. Our findings show that agent success depends not merely on obtaining correct solutions, but on how agents gather context, recognise architecture patterns, abandon unproductive searches, and achieve approximate rather than exact fault localisation. We identify distinct problem-solving styles and failure modes, highlighting that longer, more variable trajectories often signal failure and that perfect fault localisation is neither necessary nor sufficient for success. These results highlight the need to move beyond leaderboard-based evaluation and develop frameworks for building more interpretable and robust code agents.

References
----------

*   (1)
*   Anthropic (2024) Anthropic. 2024. Building Effective Agents. [https://www.anthropic.com/engineering/building-effective-agents](https://www.anthropic.com/engineering/building-effective-agents). 
*   Bouzenia et al. (2025) Islem Bouzenia, Premkumar Devanbu, and Michael Pradel. 2025. RepairAgent: An Autonomous, LLM-Based Agent for Program Repair. In _2025 IEEE/ACM 47th International Conference on Software Engineering (ICSE)_. 2188–2200. [doi:10.1109/ICSE55347.2025.00157](https://doi.org/10.1109/ICSE55347.2025.00157)ISSN: 1558-1225. 
*   Bouzenia and Pradel (2025) Islem Bouzenia and Michael Pradel. 2025. Understanding Software Engineering Agents: A Study of Thought-Action-Result Trajectories. [doi:10.48550/arXiv.2506.18824](https://doi.org/10.48550/arXiv.2506.18824)arXiv:2506.18824 [cs] version: 1. 
*   Bula et al. (2025) Timothy Bula, Saurabh Pujar, Luca Buratti, Mihaela Bornea, and Avirup Sil. 2025. SeaView: Software Engineering Agent Visual Interface for Enhanced Workflow. [doi:10.48550/arXiv.2504.08696](https://doi.org/10.48550/arXiv.2504.08696)arXiv:2504.08696 [cs] version: 2. 
*   Ceka et al. (2025) Ira Ceka, Saurabh Pujar, Shyam Ramji, Luca Buratti, Gail Kaiser, and Baishakhi Ray. 2025. Understanding Software Engineering Agents Through the Lens of Traceability: An Empirical Study. arXiv:2506.08311[cs.SE] [https://arxiv.org/abs/2506.08311](https://arxiv.org/abs/2506.08311)
*   Chen et al. (2025a) Zhi Chen, Wei Ma, and Lingxiao Jiang. 2025a. Unveiling Pitfalls: Understanding Why AI-driven Code Agents Fail at GitHub Issue Resolution. [doi:10.48550/arXiv.2503.12374](https://doi.org/10.48550/arXiv.2503.12374)arXiv:2503.12374 [cs]. 
*   Chen et al. (2025b) Zimin Chen, Yue Pan, Siyu Lu, Jiayi Xu, Claire Le Goues, Martin Monperrus, and He Ye. 2025b. Prometheus: Unified Knowledge Graphs for Issue Resolution in Multilingual Codebases. arXiv:2507.19942[cs.SE] 
*   Chowdhury et al. (2024) Neil Chowdhury, James Aung, Chan Jun Shern, Oliver Jaffe, Dane Sherburn, Giulio Starace, Evan Mays, Rachel Dias, Marwan Aljubeh, Mia Glaese, Carlos E. Jimenez, John Yang, Leyton Ho, Tejal Patwardhan, Kevin Liu, and Aleksander Madry. 2024. Introducing SWE-bench Verified. 
*   He et al. (2023) Ye He, Zimin Chen, and Claire Le Goues. 2023. Precisebugcollector: Extensible, executable and precise bug-fix collection: Solution for challenge 8: Automating precise data collection for code snippets with bugs, fixes, locations, and types. In _2023 38th IEEE/ACM International Conference on Automated Software Engineering (ASE)_. IEEE, 1899–1910. 
*   Huang et al. (2024) Xu Huang, Weiwen Liu, Xiaolong Chen, Xingmei Wang, Hao Wang, Defu Lian, Yasheng Wang, Ruiming Tang, and Enhong Chen. 2024. Understanding the planning of LLM agents: A survey. [doi:10.48550/arXiv.2402.02716](https://doi.org/10.48550/arXiv.2402.02716)arXiv:2402.02716 [cs]. 
*   Kim et al. (2024) Byoungjip Kim, Youngsoo Jang, Lajanugen Logeswaran, Geon-Hyeong Kim, Yu Jin Kim, Honglak Lee, and Moontae Lee. 2024. Prospector: Improving LLM Agents with Self-Asking and Trajectory Ranking. In _Findings of the Association for Computational Linguistics: EMNLP 2024_, Yaser Al-Onaizan, Mohit Bansal, and Yun-Nung Chen (Eds.). Association for Computational Linguistics, Miami, Florida, USA, 14958–14976. 
*   LangChain (2024) LangChain. 2024. AgentEvals. [https://github.com/SWE-bench/experiments](https://github.com/SWE-bench/experiments). 
*   LangChain (2025) LangChain. 2025. AgentEvals. [https://github.com/langchain-ai/agentevals](https://github.com/langchain-ai/agentevals). 
*   Lin et al. (2025) Jiaye Lin, Yifu Guo, Yuzhen Han, Sen Hu, Ziyi Ni, Licheng Wang, Mingguang Chen, Daxin Jiang, Binxing Jiao, Chen Hu, and Huacan Wang. 2025. SE-Agent: Self-Evolution Trajectory Optimization in Multi-Step Reasoning with LLM-Based Agents. arXiv:2508.02085 [cs] version: 1. 
*   Luo et al. ([n. d.]) Wenqiang Luo, Jacky Keung, Boyang Yang, He Ye, Claire Le Goues, Tegawende F Bissyande, Haoye Tian, and Xuan Bach D Le. [n. d.]. When Fine-Tuning LLMs Meets Data Privacy: An Empirical Study of Federated Learning in LLM-Based Program Repair. _ACM Transactions on Software Engineering and Methodology_ ([n. d.]). 
*   Martinez and Franch (2025) Matias Martinez and Xavier Franch. 2025. Dissecting the SWE-Bench Leaderboards: Profiling Submitters and Architectures of LLM- and Agent-Based Repair Systems. arXiv:2506.17208 [cs]. 
*   Meng et al. (2025) Kevin Meng, Vincent Huang, Jacob Steinhardt, and Sarah Schwettmann. 2025. Introducing Docent. [https://transluce.org/introducing-docent](https://transluce.org/introducing-docent). 
*   Pan et al. (2025) Melissa Z Pan, Mert Cemri, Lakshya A Agrawal, Shuyi Yang, Bhavya Chopra, Rishabh Tiwari, Kurt Keutzer, Aditya Parameswaran, Kannan Ramchandran, Dan Klein, et al. 2025. Why do multiagent systems fail?. In _ICLR 2025 Workshop on Building Trust in Language Models and Applications_. 
*   Song et al. (2024) Yifan Song, Weimin Xiong, Xiutian Zhao, Dawei Zhu, Wenhao Wu, Ke Wang, Cheng Li, Wei Peng, and Sujian Li. 2024. AgentBank: Towards Generalized LLM Agents via Fine-Tuning on 50000+ Interaction Trajectories. [doi:10.48550/arXiv.2410.07706](https://doi.org/10.48550/arXiv.2410.07706)arXiv:2410.07706 [cs]. 
*   Wang et al. (2024b) Lei Wang, Chen Ma, Xueyang Feng, Zeyu Zhang, Hao Yang, Jingsen Zhang, Zhiyuan Chen, Jiakai Tang, Xu Chen, Yankai Lin, Wayne Xin Zhao, Zhewei Wei, and Jirong Wen. 2024b. A survey on large language model based autonomous agents. _Frontiers of Computer Science_ 18, 6 (March 2024), 186345. [doi:10.1007/s11704-024-40231-1](https://doi.org/10.1007/s11704-024-40231-1)
*   Wang et al. (2024a) Xingyao Wang, Yangyi Chen, Lifan Yuan, Yizhe Zhang, Yunzhu Li, Hao Peng, and Heng Ji. 2024a. Executable Code Actions Elicit Better LLM Agents. In _Forty-first International Conference on Machine Learning_. [https://openreview.net/forum?id=jJ9BoXAfFa](https://openreview.net/forum?id=jJ9BoXAfFa)
*   Wang et al. (2025a) Xingyao Wang, Boxuan Li, Yufan Song, Frank F. Xu, Xiangru Tang, Mingchen Zhuge, Jiayi Pan, Yueqi Song, Bowen Li, Jaskirat Singh, Hoang H. Tran, Fuqiang Li, Ren Ma, Mingzhang Zheng, Bill Qian, Yanjun Shao, Niklas Muennighoff, Yizhe Zhang, Binyuan Hui, Junyang Lin, Robert Brennan, Hao Peng, Heng Ji, and Graham Neubig. 2025a. OpenHands: An Open Platform for AI Software Developers as Generalist Agents. In _The Thirteenth International Conference on Learning Representations_. 
*   Wang et al. (2025b) You Wang, Michael Pradel, and Zhongxin Liu. 2025b. Are ”Solved Issues” in SWE-bench Really Solved Correctly? An Empirical Study. arXiv:2503.15223 [cs]. 
*   Wei et al. (2022) Jason Wei, Xuezhi Wang, Dale Schuurmans, Maarten Bosma, Brian Ichter, Fei Xia, Ed Chi, Quoc V. Le, and Denny Zhou. 2022. Chain-of-Thought Prompting Elicits Reasoning in Large Language Models. _Advances in Neural Information Processing Systems_ 35 (Dec. 2022), 24824–24837. [https://proceedings.neurips.cc/paper/2022/hash/9d5609613524ecf4f15af0f7b31abca4-Abstract-Conference.html](https://proceedings.neurips.cc/paper/2022/hash/9d5609613524ecf4f15af0f7b31abca4-Abstract-Conference.html)
*   Xia et al. (2024) Chunqiu Steven Xia, Yinlin Deng, Soren Dunn, and Lingming Zhang. 2024. Agentless: Demystifying LLM-based Software Engineering Agents. [doi:10.48550/arXiv.2407.01489](https://doi.org/10.48550/arXiv.2407.01489)arXiv:2407.01489 [cs]. 
*   Yang et al. (2024) John Yang, Carlos E. Jimenez, Alexander Wettig, Kilian Lieret, Shunyu Yao, Karthik Narasimhan, and Ofir Press. 2024. SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering. _Advances in Neural Information Processing Systems_ 37 (Dec. 2024), 50528–50652. 
*   Ye et al. (2023) He Ye, Matias Martinez, Xiapu Luo, Tao Zhang, and Martin Monperrus. 2023. SelfAPR: Self-supervised Program Repair with Test Execution Diagnostics. In _Proceedings of the 37th IEEE/ACM International Conference on Automated Software Engineering_ (Rochester, MI, USA) _(ASE ’22)_. Association for Computing Machinery, New York, NY, USA, Article 92, 13 pages. 
*   Ye et al. (2022) He Ye, Matias Martinez, and Martin Monperrus. 2022. Neural program repair with execution-based backpropagation. In _Proceedings of the 44th International Conference on Software Engineering_ (Pittsburgh, Pennsylvania) _(ICSE ’22)_. Association for Computing Machinery, New York, NY, USA, 1506–1518. 
*   Ye and Monperrus (2024) He Ye and Martin Monperrus. 2024. Iter: Iterative neural repair for multi-location patches. In _Proceedings of the 46th IEEE/ACM international conference on software engineering_. 1–13. 
*   Ye et al. (2025) He Ye, Aidan ZH Yang, Chang Hu, Yanlin Wang, Tao Zhang, and Claire Le Goues. 2025. AdverIntent-Agent: Adversarial Reasoning for Repair Based on Inferred Program Intent. _Proceedings of the ACM on Software Engineering_ 2, ISSTA (2025), 1398–1420. 
*   Zhang et al. (2024) Yuntong Zhang, Haifeng Ruan, Zhiyu Fan, and Abhik Roychoudhury. 2024. AutoCodeRover: Autonomous Program Improvement. In _Proceedings of the 33rd ACM SIGSOFT International Symposium on Software Testing and Analysis_ _(ISSTA 2024)_. Association for Computing Machinery, New York, NY, USA, 1592–1604.

## Figures

### Figure 1a: Resolved Issues Venn Diagram (SWE-bench Lite)
![Figure 1a](../../../../_media/agent-trajectories-fig1-lite-venn.png)
*Resolved issues overlap across agents on SWE-bench Lite. Different agents solve different subsets.*

### Figure 1b: Resolved Issues Venn Diagram (SWE-bench Verified)
![Figure 1b](../../../../_media/agent-trajectories-fig2-verified-venn.png)
*Resolved issues overlap across agents on SWE-bench Verified.*

### Figure 2: Trajectory Step Counts (SWE-bench Lite)
![Figure 2](../../../../_media/agent-trajectories-fig3-violin-lite.png)
*Violin plots of trajectory step counts in SWE-bench Lite, comparing successful and failed trajectories.*

### Figure 3: Trajectory Step Counts (SWE-bench Verified)
![Figure 3](../../../../_media/agent-trajectories-fig4-violin-verified.png)
*Violin plots of trajectory step counts in SWE-bench Verified.*

### Figure 4: Fault Localization Combination Outcomes
![Figure 4](../../../../_media/agent-trajectories-fig5-faultloc.png)
*Proportion of fault localization combination outcomes across file, function, and hunk levels.*
