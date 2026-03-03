---
created: 2026-02-21
description: A complete roadmap of the math needed for systematic trading, covering statistics and probability, linear algebra, time series analysis, and risk management with practical trading applications for each concept.
source: https://x.com/GoshawkTrades/status/2013686516531524083
type: framework
---

## Key Takeaways

The roadmap covers six domains but the minimum viable toolkit is surprisingly small: mean, median, standard deviation, correlation, basic probability, Sharpe ratio, and max drawdown. That alone separates you from most newcomers. Everything else is depth — and the depth determines whether your edge is real or overfitted noise. This connects directly to [[kelly criterion determines optimal prediction market bet size from three inputs|Kelly criterion sizing]], which is just applied expected value and probability theory.

Sample size is the most underrated concept: a 10-0 backtest proves nothing, while hundreds of trades across years of out-of-sample data tell you something real about edge. The Law of Large Numbers is why [[mathematical infrastructure not luck extracted 40 million from Polymarket|mathematical infrastructure]] beats luck — aggregates become predictable even when individual trades are random. The Central Limit Theorem justifies using normal-distribution tools even on messy data, because portfolio-level returns normalize.

Conditional probability and Bayes' Theorem are where regime-aware trading lives. A strategy with 55% overall win rate might be 70% in low-VIX and 35% in high-VIX — knowing which regime you're in changes everything. This is the mathematical foundation behind [[hedge funds use prediction market data for risk calibration not outcome prediction|institutional risk calibration]]: update beliefs systematically as new evidence arrives rather than anchoring on priors.

Cointegration (section 4.5) is the mathematical foundation of pairs trading: two trending assets whose spread is stationary. You're not betting on direction but on the spread returning to normal. PCA (section 2.4) solves the "50 correlated indicators" problem by finding the 5 underlying factors that explain 90% of variance — trading 5 independent signals instead of 50 noisy ones.

Monte Carlo simulation appears again here (section 5.5) as it does in [[kelly criterion determines optimal prediction market bet size from three inputs|Kelly-Monte Carlo strategies]]: your backtest is one sequence of trades, but Monte Carlo randomizes order across thousands of simulations to show the range of possible outcomes, not just the one path you observed. The worst drawdown may not have happened yet.

## External Resources

- [Quantitative Trading by Ernie Chan](https://www.amazon.com/Quantitative-Trading-Build-Algorithmic-Business/dp/1119800064) — How to build your own algorithmic trading business
- [Algorithmic Trading by Ernie Chan](https://www.amazon.com/Algorithmic-Trading-Winning-Strategies-Rationale/dp/1118460146) — Winning strategies and their rationale
- [Time Series Analysis by Hamilton](https://www.amazon.com/Time-Analysis-James-Douglas-Hamilton/dp/0691042896) — Definitive reference for time series (dense but comprehensive)
- [Analysis of Financial Time Series by Tsay](https://www.amazon.com/Analysis-Financial-Time-Ruey-Tsay/dp/0470414359) — Time series focused on financial applications
- [The Mathematics of Money Management by Ralph Vince](https://www.amazon.com/Mathematics-Money-Management-Analysis-Techniques/dp/0471547387) — Classic text on position sizing
- [Testing and Tuning Market Trading Systems by Timothy Masters](https://www.amazon.com/Testing-Tuning-Market-Trading-Systems/dp/148424172X) — How to test strategies without overfitting

## Original Content

> [!quote]- Full article by @GoshawkTrades: The Math Needed for Trading (Complete Roadmap)
> I'm going to break down the essential math you need for trading. I'll also share the exact roadmap and resources that helped me personally.
>
> Let's get straight to it.
>
> This roadmap is for traders who want to use data. Whether that's backtesting strategies, building algorithms, or running systematic approaches. If you want to trade based on evidence, patterns, and probability—this is your foundation.
>
> **I – Statistics and Probability**
>
> The foundation of extracting signal from noise. Every price move is a combination of signal and randomness. Statistics gives you the tools to separate the two.
>
> **1.1 Sample Size and the Law of Large Numbers**
>
> Sample size is crucial because it leads to the Law of Large Numbers. The bigger your sample, the closer your results get to the true expectation.
>
> In trading: more trades = more accurate backtest. A strategy that's 10-0 in backtesting isn't impressive. It's insufficient data. A strategy that has hundreds or thousands tells you something real about edge. This is why you need years of data and hundreds of trades before trusting a backtest. Plus it needs to be out of sample.
>
> **1.2 Central Tendency: Finding the Middle**
>
> Mean: Add all values and divide by count. Moving averages are just rolling means.
>
> Median: The middle value when sorted. Better than mean when outliers exist (and they always exist in trading). If you have 9 small losses and 1 massive Black Swan event, median shows the typical outcome better than mean.
>
> Mode: Most frequent value. Almost useless in continuous data like prices. Occasionally useful for analyzing price clustering at round numbers.
>
> Expected Value: Weighted average of all possible outcomes. This is what you're actually trying to maximize in trading: (Win% × Avg Win) - (Loss% × Avg Loss)
>
> **1.3 Spread: How Much Things Vary**
>
> Variance: Average of squared differences from the mean. Mathematical foundation of risk.
>
> Standard Deviation: Square root of variance. Same information as variance, but in the same units as your data (dollars, percent, etc.) This becomes volatility when applied to returns. Every position sizing formula uses volatility. Every risk metric uses standard deviation. If you don't understand this, you can't size positions intelligently.
>
> **1.4 Correlation: Do Things Move Together?**
>
> Covariance: Raw measure of how two variables co-move. Positive = tend to move together. Negative = tend to move opposite. Zero = no relationship.
>
> Correlation: Standardized covariance from -1 to +1. This tells you if your strategies are actually independent. Running 3 momentum strategies on correlated assets gives you 3x the size but not 3x the diversification. Correlation = 0.9? You basically have one strategy. Correlation = 0.2? Now you have real diversification.
>
> **1.5 Probability Distributions**
>
> Normal (Gaussian): The bell curve. Many models assume normality; real returns are heavy-tailed, so Gaussian approximations can understate crashes.
>
> Binomial: Binary outcomes. Win or lose. Up day or down day. Used for modeling discrete events.
>
> Uniform: Everything equally likely. Useful as a baseline assumption when you have no information.
>
> Understanding which distribution fits your data determines which statistical tools work.
>
> **1.6 Central Limit Theorem**
>
> The average of many random variables approaches a normal distribution, regardless of the underlying distribution. This means: Portfolio returns are more normal than individual stock returns. Average of 100 trades is more predictable than any single trade. Even if individual outcomes are messy, aggregates become clean. This justifies using normal-based statistics even when individual data points aren't normal.
>
> **1.7 Conditional Probability**
>
> The probability of X given Y. Markets have regimes. Your strategy performs differently in different conditions.
>
> Example: P(strategy wins) might be 55%. P(strategy wins | VIX > 30) might be 35%. P(strategy wins | VIX < 15) might be 70%.
>
> Understanding conditional probabilities lets you filter for favorable conditions.
>
> **1.8 Bayes' Theorem**
>
> How to update your beliefs when new evidence arrives. Prior belief + New evidence = Updated belief.
>
> Example: You think a stock has 60% chance of going up tomorrow. Earnings come out and beat expectations. What's the new probability? Bayes' Theorem gives you a systematic way to update probabilities based on new information. Critical for adaptive strategies and regime-based trading.
>
> **1.9 Maximum Likelihood Estimation**
>
> How do you find the best parameters for a model? MLE says: pick the parameters that make your observed data most likely. This is why we minimize squared error in regression—it's the maximum likelihood solution under Gaussian noise. Understanding MLE explains why loss functions are designed the way they are.
>
> **1.10 Regression Models**
>
> Linear Regression: Fit a line to data. Used for mean reversion (price deviates from trend line, reverts back), predicting continuous values, understanding relationships between variables.
>
> Logistic Regression: Predict binary outcomes. Used for up/down day prediction, win/loss probability, binary classification.
>
> Both are building blocks for more complex models.
>
> **II – Linear Algebra: The math of portfolios**
>
> Once you're trading multiple positions or running multiple strategies, you're doing linear algebra.
>
> **2.1 Scalars, Vectors, Matrices**
>
> Scalar: Single number (one day's return for one stock). Vector: Column of numbers (returns for 10 stocks on the same day). Matrix: Grid of numbers (252 days of returns for 10 stocks = 252×10 matrix). Your portfolio is a weighted sum of vectors. Risk calculation is matrix multiplication.
>
> **2.2 Matrix Operations**
>
> Addition: Combine signals or returns. Multiplication: Apply weights to positions. Transpose: Flip rows and columns. Example: Portfolio return = (weight vector) × (return vector).
>
> **2.3 Eigenvalues and Eigenvectors**
>
> These reveal the "principal directions" of your data. In trading: Which factors actually drive your portfolio? How many independent sources of return do you have? What's your true diversification? Used in risk modeling and portfolio optimization.
>
> **2.4 Decomposition Methods**
>
> SVD: Break a matrix into simpler components. PCA: Find the most important patterns in data.
>
> Real application: You have 50 technical indicators. Most are correlated. PCA finds the 5 underlying "factors" that explain 90% of the variation. Now you can trade on 5 independent signals instead of 50 noisy ones.
>
> **III – Time Series Analysis: Markets have memory and structure**
>
> Today's price depends on yesterday's. Volatility clusters. Trends persist. Time series analysis models these dependencies.
>
> **4.1 Stationarity**
>
> A time series is stationary if its statistical properties stay constant over time. Most statistical tests assume stationarity. Problem: Markets aren't stationary. Volatility changes. Correlations shift. Market structure evolves. A strategy that works on stationary data might fail when the underlying process changes. This is why strategies decay — the market regime shifts and your model assumes it hasn't.
>
> **4.2 Autocorrelation**
>
> How much does today's value depend on yesterday's? Positive autocorrelation: Yesterday up → today likely up (momentum). Negative autocorrelation: Yesterday up → today likely down (mean reversion). Zero autocorrelation: No pattern (random walk).
>
> **4.3 ARIMA Models**
>
> AutoRegressive Integrated Moving Average. Framework for forecasting time series. AR: Today depends on previous days. I: Account for trends. MA: Today depends on previous errors. Used for predicting returns, volatility, or any variable that evolves over time.
>
> **4.4 GARCH Models**
>
> Generalized AutoRegressive Conditional Heteroskedasticity. "Volatility clusters and changes over time." After a big move, expect more volatility. After calm periods, expect continued calm. If you're sizing positions based on recent volatility (which you should), GARCH formalizes this.
>
> **4.5 Cointegration**
>
> Two assets can both be non-stationary (trending), but their difference is stationary.
>
> Example: Stock A trends from $50 to $150. Stock B trends from $45 to $135. Spread (A - B) oscillates around $5. The spread is stationary even though both stocks trend.
>
> This is the foundation of pairs trading. You're not betting on direction. You're betting the spread returns to normal.
>
> **IV – Risk Management Math: How to not blow up**
>
> Edge doesn't matter if you size wrong.
>
> **5.1 Value at Risk (VaR)**
>
> Maximum expected loss at a given confidence level. 95% VaR = $5,000 means: 95% of the time, you won't lose more than $5,000. But 5% of the time, you might lose more (possibly much more).
>
> **5.2 Sharpe Ratio**
>
> Risk-adjusted return. Sharpe = (Return - Risk-Free Rate) / Volatility. Measures how much return you get per unit of risk. Lower volatility = higher Sharpe = better risk-adjusted performance.
>
> **5.3 Maximum Drawdown**
>
> Biggest peak-to-trough loss. More intuitive than volatility for most people. Critical question: Can you psychologically handle that? Can your account survive it without hitting margin calls?
>
> **5.5 Monte Carlo Simulation**
>
> Your backtest shows one sequence of trades. Monte Carlo randomizes the order and runs thousands of simulations. Maybe your backtest got lucky with trade sequencing. Maybe the worst drawdown hasn't happened yet. Monte Carlo shows the range of possible outcomes, not just the one path you observed.
>
> **VI – What You Actually Need**
>
> You don't need all of this to start. But you need to know what you don't know.
>
> Minimum for backtesting strategies: Mean, median, standard deviation. Correlation. Basic probability. Sharpe ratio, max drawdown. Start with statistics. That alone separates you from most newcomers.
>
> **Recommended Books:**
> - Quantitative Trading by Ernie Chan
> - Algorithmic Trading by Ernie Chan
> - Time Series Analysis by Hamilton
> - Analysis of Financial Time Series by Tsay
> - The Mathematics of Money Management by Ralph Vince
> - Testing and Tuning Market Trading Systems by Timothy Masters
>
> Thanks for reading. – Mounir
>
> [Original post](https://x.com/GoshawkTrades/status/2013686516531524083)
