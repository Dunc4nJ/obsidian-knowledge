---
created: 2026-03-10
description: A walkthrough of building a Conv1D+LSTM neural network with Monte Carlo dropout that processes 38 indicators across 30 prediction market contracts, achieving 59-78% win rate on unseen data.
source: https://x.com/noisyb0y1/status/2031661714987454664
type: learning
---

## Key Takeaways

The core architecture combines Conv1D (local pattern detection) with LSTM (long-term memory) and a sigmoid output for binary classification — will this contract go up tomorrow? This is the same directional-bet framing that [[prediction markets are the purest test of quantitative finance because every position resolves to truth]] describes as the fundamental prediction market structure.

The Monte Carlo Dropout technique is the most interesting piece: instead of one prediction, the model runs 50 forward passes with different dropout masks and only trades when there's consensus (low standard deviation). This is essentially a built-in calibration mechanism — related to the calibration surface analysis in [[hedge funds use prediction market data for risk calibration not outcome prediction]].

The 38-indicator feature set spans technical (MA, RSI, MACD, Bollinger), volume (OBV), volatility, sentiment, and insider activity. The model processes 30 contracts simultaneously over 60-day windows — far beyond what any human could track manually.

Train/test split is temporal (2000-2020 train, 2021-2025 test) which avoids data leakage — the most common mistake in ML trading systems. The reported 59% baseline accuracy sounds modest but with 100+ trades per month and proper position sizing, the edge compounds.

The trading strategy is simple: each day, buy the top 3 positions with highest predicted probability of going up, only when confidence exceeds 70%. This selective approach — waiting for strong signals rather than trading everything — mirrors the [[Part 1 designing a production grade agentic MLOps system|production MLOps approach]] of using LSTM with transfer learning for market prediction.

The backtest chart shows the strategy (green line) consistently beating 10 random strategies (grey lines), with win rates sometimes reaching 78%.

## External Resources

- Full code available on GitHub (linked in original thread)
- Polymarket — primary prediction market platform referenced

## Original Content

> [!quote]- Source Material
>
> **@noisyb0y1 (Noisy)** — Wed Mar 11, 2026
> 1060 likes · 91 retweets · 43 replies
>
> *Article: 25 years of data, 38 indicators, 50 predictions at once - 79% win rate on Prediction markets*
>
> If you train an AI agent on 25 years of market data, can you realistically make $20k/month from it?
>
> Spoiler: by the end you'll understand why 10x on prediction markets is possible if you catch the right moment
>
> ![[noisyb0y1-454664-001.jpg]]
>
> The human brain can tracks max 19 things at once. Prediction markets move on hundreds of variables: news, volume, momentum, whales, sentiment - all at the same time.
>
> Manually impossible. But code can.
>
> This bot will open 100+ trades already knowing their scenario. Even if we hit 64% win rate - that's already profit
>
> **Phase 1 - Time Horizons**
>
> On Prediction markets there are many time horizons:
> - 1 Day
> - 7 Days
> - 30 Days
>
> The model can predict across different horizons, but in this piece, the focus is 1 Day. Will this prediction market contract resolve YES tomorrow?
>
> Starting simple - just one day. If you can consistently call the direction 1 day ahead, that's already a working tool for daily trading
>
> ![[noisyb0y1-454664-002.jpg]]
>
> **Phase 2 - What the model predicts (predict classification)**
>
> ```python
> def add_features(df: pd.DataFrame) -> pd.DataFrame:
>     df["Target1"] = (df["close"].shift(-1) > df["close"]).astype(int)
> ```
>
> Target1 = 1 -> tomorrow higher -> BUY
> Target1 = 0 -> tomorrow lower -> DONT BUY
>
> Simple - the model doesn't try to predict the exact price. It answers one question only: up or down?
>
> Same logic as Polymarket contracts - you're betting on an event, not an exact number
>
> ![[noisyb0y1-454664-003.jpg]]
>
> **Phase 3 - 38 indicators that lead us to the result**
>
> ```python
> MA10, MA20, MA30          — moving averages
> RSI                       — overbought/oversold
> MACD, MACD_Signal         — trend
> BollingerUpper/Lower      — volatility bands
> Volatility_10/20/30       — price fluctuation intensity
> OBV                       — buyer/seller pressure
> sentiment, num_articles   — news flow
> insider_shares/amount     — insider activity
> momentum_5d / momentum_20d
> ```
>
> The model doesn't just look at price - it analyzes 38 different signals across 30 prediction market contracts over the last 60 days
>
> Imagine manually analyzing 38 indicators across 30 contracts every day
>
> ![[noisyb0y1-454664-004.jpg]]
>
> **Phase 4 - How we split the data by time**
>
> ```python
> train_val_cutoff = global_min_date + (global_max_date - global_min_date) * 0.8
> train_cutoff     = global_min_date + (train_val_cutoff - global_min_date) * (1 - 0.2)
>
> Training (2000–2020): BTC, S&P500, ETH, major prediction markets
> Testing (2021–2025): same markets, but future the model never saw
> ```
>
> Important - model learns on the past, gets tested on the future. No data leakage
>
> This is the most common mistake people make building these systems - they test on the same data they trained on. We don't do that. The model never saw 2021-2025 during training - that's a clean honest test
>
> ![[noisyb0y1-454664-005.jpg]]
>
> **Phase 5 - Neural network architecture**
>
> ```
> model = Sequential([
>     Conv1D(32, kernel_size=3, activation="relu",
>            input_shape=(WINDOW_SIZE + 1, n_features)),
>     BatchNormalization(),
>     MCDropout(0.2),
>     LSTM(64, return_sequences=False),
>     MCDropout(0.2),
>     Dense(32, activation="relu"),
>     Dense(1, activation="sigmoid"),
> ])
> model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])
> ```
>
> - Conv1D - finds local patterns in the time series
> - LSTM - remembers long-term dependencies
> - MCDropout - measures prediction uncertainty
> - Sigmoid - outputs a number from 0 to 1 (probability)
>
> The model outputs just one number. Say 0.85 - means the model is 85% confident price goes up tomorrow. You decide whether to trust it
>
> ![[noisyb0y1-454664-006.jpg]]
>
> **Phase 6 - Monte Carlo Dropout (key part)**
>
> ```python
> class MCDropout(Dropout):
>     def call(self, inputs, training=None):
>         return super().call(inputs, training=True)
>
> def mc_dropout_predict(model, X, n_samples=50):
>     preds = np.array([model(X, training=True).numpy() for _ in range(n_samples)])
>     return preds.mean(axis=0), preds.std(axis=0), preds
> ```
>
> Instead of a single prediction, we run the model 50 times with different dropout rates. We get the mean (confidence) and std (uncertainty).
> If the model disagrees with itself, we don't buy
>
> Think of it like asking 50 analysts at once. If all 50 say BUY, we enter. If half say BUY and half say HOLD - we skip.
>
> We only trade when there's consensus
>
> ![[noisyb0y1-454664-007.jpg]]
>
> **Phase 7 - BUY/HOLD signal**
>
> ```python
> Date        Close   Prob_Up_1  Prob_Std_1  Signal_1
> 2020-06-17  95.74   0.9995     0.0008      BUY
> 2020-06-23  97.31   5.45e-05   0.0         HOLD
> 2020-06-26  96.13   0.9995     0.0008      BUY
>
> result[f"Signal_{h}"] = [
>     "BUY" if p > 0.7 else "HOLD"
>     for p in y_pred_mean[:, i]
> ]
> ```
>
> Confidence threshold is 70%. If the model says BUY with less than 70% confidence - we ignore the signal and keep looking
>
> We don't trade every day on every market. We wait for strong signals only. 3 confident trades a week beats 20 uncertain ones
>
> ![[noisyb0y1-454664-008.jpg]]
>
> **Phase 8 - Training**
>
> ```python
> callbacks = [
>     EarlyStopping(monitor="val_loss", min_delta=1e-7, patience=15),
>     ReduceLROnPlateau(monitor="val_loss", factor=0.5, min_lr=1e-7, patience=10),
> ]
> history = model.fit(train_gen, validation_data=val_gen, epochs=50)
> ```
>
> ~59% accuracy sounds modest - but on prediction markets, even 59% win rate gives consistent profit
>
> Casinos make money with just a 2-3% edge. We have 59%. With 100+ trades a month, the math works in our favor
>
> **Phase 9 - Final result**
>
> Strategy is simple - every day we buy the top 3 positions with the highest probability of going up.
>
> ![[noisyb0y1-454664-009.jpg]]
>
> The grey lines are 10 people opening random prediction market positions every day. The green line is our bot. Difference is obvious!
>
> Result consistently beats random strategies and already gives more than 59% win rate - sometimes hitting 78%
>
> Every signal, every indicator, every pattern across 30 markets - processed in seconds. Not by you. By a model that runs 24/7
>
> We took 25 years of market data, compressed it into 38 indicators, ran it through an LSTM neural network 50 times per prediction - and the result consistently beats random strategies.
>
> Full code on GitHub. Every one of you can try running it on your old laptop and increase your chances of successful trading
>
> [Original tweet](https://x.com/noisyb0y1/status/2031661714987454664)
