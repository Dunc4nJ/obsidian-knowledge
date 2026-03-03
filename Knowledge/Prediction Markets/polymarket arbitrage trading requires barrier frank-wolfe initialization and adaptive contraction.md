---
created: 2026-02-05
description: A production-grade Polymarket arbitrage system needs more than the Frank–Wolfe theory — it must solve initialization, gradient stability via barrier contraction, and profit-guaranteed stopping rules before execution.
source: https://x.com/rohonchain/status/2019131428378931408
type: framework
---

# Polymarket arbitrage trading requires barrier Frank-Wolfe initialization and adaptive contraction

## Core claim
A serious Polymarket arbitrage bot is primarily an **implementation** problem: you must (1) initialize Frank–Wolfe on a feasible active set, (2) prevent LMSR gradient blowups via barrier Frank–Wolfe with adaptive contraction, and (3) use a profit-guarantee stopping condition to trade before the opportunity decays.

## Key takeaways

- **Initialization is a first-class algorithm, not a footnote.** The thread argues you can’t start Frank–Wolfe with “random numbers”; you need a feasible initial active set and an interior point so the method doesn’t fail immediately. This is a concrete extension of the “math → money” gap described in [[mathematical infrastructure not luck extracted 40 million from Polymarket]].

- **LMSR breaks standard smoothness assumptions, so you need a barrier/contracted polytope.** The practical failure mode is gradient explosion near the boundary (coordinates approaching 0). The proposed fix is to optimize over a contracted polytope pulled toward a strictly interior point, shrinking the contraction parameter over time. This is exactly the kind of “systems math under load” requirement [[moc - Polytrader]] is meant to operationalize.

- **Stop-and-trade must be driven by guaranteed profit, not convergence aesthetics.** The thread highlights a profit lower bound of the form “divergence minus FW gap,” and recommends stopping once you’re guaranteed to capture a high fraction (e.g., 90%) of available arbitrage. For automated execution, this belongs in the same decision layer as risk limits and execution mode gates in [[moc - Polytrader]].

- **Arbitrage persists because market makers choose speed over consistency.** The argument is that platforms accept some systematic mispricing because arbitrageurs provide volume/liquidity and because losses are bounded under cost-function market makers. This frames arbitrage windows as structural (not “bugs”), and complements the broader prediction-market framing under [[moc - Knowledge]].

## External resources mentioned

- Kroer et al. (2016), “Arbitrage-Free Combinatorial Market Making via Integer Programming” — https://arxiv.org/abs/1606.02825
- Saguillo et al. (2025), “Unravelling the Probabilistic Forest: Arbitrage in Prediction Markets” — https://arxiv.org/abs/2508.03474
- Gurobi Optimizer — https://www.gurobi.com/
- Polymarket documentation — https://docs.polymarket.com/

## Original content

> **@RohOnChain (Roan)** — Wed Feb 04 2026
>
> Article: The Math Needed for Trading on Polymarket (Complete Roadmap) - Part 2
>
> The thread walks through: (1) an explicit initialization procedure for Frank–Wolfe in combinatorial markets, (2) barrier Frank–Wolfe with adaptive contraction to avoid LMSR gradient explosion, (3) a profit-guarantee stopping rule (capture ~90% of available arbitrage), and (4) why market makers tolerate arbitrage as a speed/liquidity tradeoff.
>
> Source: https://x.com/RohOnChain/status/2019131428378931408
>
> Engagement at capture time: 606 likes, 40 reposts, 16 replies
