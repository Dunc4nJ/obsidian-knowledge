---
created: 2026-07-18
description: Jon Kleinberg's Cornell CS/IS 6850 "The Structure of Information Networks" (Fall 2024) — a graduate course and curated reading list on how social and technological networks share common structure, organized around small-world/decentralized search, cascading behavior/diffusion, and spectral analysis/random walks.
source: https://www.cs.cornell.edu/courses/cs6850/2024fa/
type: reference
---

## Key Takeaways

- The course's throughline (Jon Kleinberg) is that networks across wildly different domains — social, technological, the Web — exhibit common qualitative structure that combinatorial and probabilistic techniques can expose; the prerequisites (algorithms, graphs, probability, linear algebra, light programming) signal that this is a mathematical treatment of real network data, not a soft "network science" survey.
- Pillar 1, small-world properties and decentralized search: large networks have short paths between almost all node pairs *despite* heavy local clustering, and — the deeper result — are navigable to a target using only local knowledge (Milgram's experiment; Kleinberg's decentralized-search model), which transfers directly to designing peer-to-peer systems (Chord-style lookup) and nearest-neighbor search in growth-restricted metric spaces.
- Pillar 2, cascading behavior: treating a network as a circulatory system through which information, innovation, or failure diffuses, formalized via Granovetter threshold models, probabilistic contagion, and influence-maximization (finding influential node sets) — and inverted into a design principle as epidemic / gossip-based algorithms that propagate state across distributed hosts using randomization.
- Pillar 3, spectral analysis and random walks: the eigenvalues/eigenvectors of a graph's adjacency matrix encode combinatorial structure, powering graph partitioning (Spielman–Teng spectral partitioning), random-walk analysis, and link-analysis algorithms (PageRank/HITS-lineage) for web search — with Kleinberg noting the spectral-to-combinatorial connection is powerful but still not fully understood.
- The reading list is a self-contained curriculum anchored on Easley & Kleinberg's freely available textbook *Networks, Crowds, and Markets* (chapters 14, 19, 20, 21) plus Kleinberg's own lecture notes on random graphs/expansion, spectral analysis, and random walks; assessment is two problem sets, a short reaction paper, and a substantial project.

## External Resources

- [Jon Kleinberg's homepage](http://www.cs.cornell.edu/home/kleinber/) — the instructor; author of much of the assigned work.
- [Networks, Crowds, and Markets: Reasoning About a Highly Connected World (Easley & Kleinberg, 2010)](http://www.cs.cornell.edu/home/kleinber/networks-book/) — the free textbook underpinning the course (chapters 14.6, 19.7, 20.7, 21.8 assigned).
- Lecture notes: [Random Graphs and Expansion](https://www.cs.cornell.edu/courses/cs6850/2024fa/random-expander.pdf), [Spectral Analysis of Graphs](https://www.cs.cornell.edu/courses/cs6850/2024fa/spectral.pdf), [Random Walks in Graphs](https://www.cs.cornell.edu/courses/cs6850/2024fa/random-walks.pdf).
- Seminal papers cited: Travers & Milgram (small-world experiment), Dodds/Muhamad/Watts (global social search, Science 2003), Kleinberg (Complex Networks and Decentralized Search, ICM 2006), Granovetter (threshold models, 1978), Spielman & Teng (spectral partitioning, FOCS 1996), Karger & Ruhl (nearest neighbors in growth-restricted metrics, STOC 2002), Balakrishnan et al. (Looking up data in P2P systems / Chord).
- [Coursework page](https://www.cs.cornell.edu/courses/cs6850/2024fa/coursework.html) — problem sets, reaction paper, and project details.

## Original Content

> [!quote]- Source Material — The Structure of Information Networks (CS/IS 6850, Cornell, Fall 2024)
> #  The Structure of Information Networks
>
> ##  Computer Science / Information Science 6850
> Cornell University
> Fall 2024
>
> Time: Mondays and Wednesdays at 10:10-11:25  Place: G01 Gates Hall [http://www.cs.cornell.edu/courses/cs6850/](http://www.cs.cornell.edu/courses/cs6850/)
>
> ##  Course Staff
>
> Instructor: [Jon Kleinberg](http://www.cs.cornell.edu/home/kleinber/) TAs: [Katy Blumer](https://scholar.google.com/citations?user=fkpwCJ0AAAAJ&hl=en), [Wenzhi Li](https://wenzhilics.github.io/), and [Emily Ryu](https://emilyryu.github.io/).  Office hours:  Jon: Monday 2:30-3:30pm, 318 Gates.  Katy: Wednesday 12-1pm, 400 Rhodes.  Emily: Wednesday 3-4pm, 402 Rhodes.
> * Wenzhi: Thursday 3:30-4:30pm, 402 Rhodes.
>
> ##  Overview
>
> The past two decades have seen a convergence of social and technological networks, with systems such as the World Wide Web characterized by the interplay between rich information content, the millions of individuals and organizations who create it, and the technology that supports it. This course covers recent research on the structure and analysis of such networks, and on models that abstract their basic properties. Topics include combinatorial and probabilistic techniques for link analysis, centralized and decentralized search algorithms, network models based on random graphs, and connections with work in the social sciences.
>
> The course prerequisites include introductory-level background in algorithms, graphs, probability, and linear algebra, as well as some basic programming experience (to be able to manipulate network datasets).
>
> The [work for the course](https://www.cs.cornell.edu/courses/cs6850/2024fa/coursework.html) will consist primarily of two problem sets, a short reaction paper, and a more substantial project.
>
> ##  Course Outline
>
> (1) **Random Graphs and Small-World Properties** A major goal of the course is to illustrate how networks across a variety of domains exhibit common structure at a qualitative level. One area in which this arises is in the study of \`small-world properties' in networks: many large networks have short paths between most pairs of nodes, even though they are highly clustered at a local level, and they are searchable in the sense that one can navigate to specified target nodes without global knowledge. These properties turn out to provide insight into the structure of large-scale social networks, and, in a different direction, to have applications to the design of decentralized peer-to-peer systems.  Small-world experiments in social networks. J. Travers and S. Milgram. [An experimental study of the small world problem.](http://www.cis.upenn.edu/~mkearns/teaching/NetworkedLife/travers_milgram.pdf) Sociometry 32(1969). J. Kleinfeld. [Could it be a Big World After All? The \`Six Degrees of Separation' Myth.](https://www.math.cmu.edu/~af1p/Teaching/INFONET/Papers/SmallWorld/big_world.html) Society, April 2002.
> * Peter Sheridan Dodds, Roby Muhamad, Duncan J. Watts. [An Experimental Study of Search in Global Social Networks.](http://www.dcg.ethz.ch/lectures/fs10/seminar/paper/michael-6.pdf) Science 301(2003), 827.
> * Basic Random Graph Models, and the Consequences of Expansion.
> * [Notes on Random Graphs and Expansion.](https://www.cs.cornell.edu/courses/cs6850/2024fa/random-expander.pdf)
> * Decentralized Search in Networks.
> J. Kleinberg. [Complex Networks and Decentralized Search Algorithms.](http://www.cs.cornell.edu/home/kleinber/icm06-swn.pdf) Proceedings of the International Congress of Mathematicians (ICM), 2006.
> * [Section 20.7](http://www.cs.cornell.edu/home/kleinber/networks-book/networks-book-ch20.pdf) of D. Easley, J. Kleinberg. [Networks, Crowds, and Markets: Reasoning About a Highly Connected World.](http://www.cs.cornell.edu/home/kleinber/networks-book/) Cambridge University Press, 2010.
> Decentralized Search in Peer-to-Peer Systems
> * H. Balakrishnan, M.F. Kaashoek, D. Karger, R. Morris, and I. Stoica. [Looking up data in P2P systems.](http://www.cs.berkeley.edu/~istoica/papers/2003/cacm03.pdf) Communications of the ACM 46:43-48, February 2003.
> Nearest-Neighbor Search in Metric Spaces
> * David R. Karger, Matthias Ruhl. [Finding nearest neighbors in growth-restricted metrics.](http://people.csail.mit.edu/ruhl/papers/2002-stoc.pdf) STOC 2002: 741-750
>
> (2) **Cascading Behavior in Networks** We can think of a network as a large circulatory system, through which information continuously flows. This diffusion of information can happen rapidly or slowly; it can be disastrous -- as in a panic or cascading failure -- or beneficial -- as in the spread of an innovation. Work in several areas has proposed models for such processes, and investigated when a network is more or less susceptible to their spread. This type of diffusion or cascade process can also be used as a design principle for network protocols. This leads to the idea of _epidemic algorithms_, also called _gossip-based algorithms_, in which information is propagated through a collection of distributed computing hosts, typically using some form of randomization.  Models of Collective Action.
> * M. Granovetter. [Threshold models of collective behavior.](http://www.sscnet.ucla.edu/polisci/faculty/chwe/ps269/granovetter.pdf) American Journal of Sociology 83(6):1420-1443, 1978.
> Threshold-Based Models of Diffusion in Networks.
> * [Section 19.7](http://www.cs.cornell.edu/home/kleinber/networks-book/networks-book-ch19.pdf) of D. Easley, J. Kleinberg. [Networks, Crowds, and Markets: Reasoning About a Highly Connected World.](http://www.cs.cornell.edu/home/kleinber/networks-book/) Cambridge University Press, 2010.
> Simple Probabilistic Models of Contagion.
> * [Section 21.8](http://www.cs.cornell.edu/home/kleinber/networks-book/networks-book-ch21.pdf) of D. Easley, J. Kleinberg. [Networks, Crowds, and Markets: Reasoning About a Highly Connected World.](http://www.cs.cornell.edu/home/kleinber/networks-book/) Cambridge University Press, 2010.
> Finding Influential Sets of Nodes.
> * J. Kleinberg. [Cascading Behavior in Networks: Algorithmic and Economic Issues.](http://www.cs.cornell.edu/home/kleinber/agtbook-ch24.pdf) In Algorithmic Game Theory (N. Nisan, T. Roughgarden, E. Tardos, V. Vazirani, eds.), Cambridge University Press, 2007.
>
> (3) **Spectral Analysis and Random Walks in Networks** One can gain a lot of insight into the structure of a network by analzing the eigenvalues and eigenvectors of its adjacency matrix. The connection between spectral parameters and the more combinatorial properties of networks and datasets is a subtle issue, and while many results have been established about this connection, it is still not fully understood. This connection has also led to a number of applications, including the development of link analysis algorithms for Web search.  Graph Partitioning [Notes on Spectral Analysis of Graphs.](https://www.cs.cornell.edu/courses/cs6850/2024fa/spectral.pdf)
> * Daniel A. Spielman and Shang-Hua Teng. [Spectral Partitioning Works: Planar graphs and finite element meshes.](http://www.eecs.berkeley.edu/Pubs/TechRpts/1996/CSD-96-898.pdf) Proceedings of the 37th Annual IEEE Conference on Foundations of Computer Science, 1996.
> Random Walks
> * [Notes on Random Walks in Graphs.](https://www.cs.cornell.edu/courses/cs6850/2024fa/random-walks.pdf)
> Link Analysis and Web Search [Section 14.6](http://www.cs.cornell.edu/home/kleinber/networks-book/networks-book-ch14.pdf) of D. Easley, J. Kleinberg. [Networks, Crowds, and Markets: Reasoning About a Highly Connected World.](http://www.cs.cornell.edu/home/kleinber/networks-book/) Cambridge University Press, 2010.
>
> [Original course page](https://www.cs.cornell.edu/courses/cs6850/2024fa/)
