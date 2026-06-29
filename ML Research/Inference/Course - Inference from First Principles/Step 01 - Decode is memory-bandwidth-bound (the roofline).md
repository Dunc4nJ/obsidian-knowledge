---
created: 2026-06-29
description: Step 1 of the inference course — why generating one token reads the entire model from HBM (decode is memory-bandwidth-bound), the two-clocks model, precision/bytes-per-weight, the multiply-accumulate (2 FLOPs/weight), and the ridge point B*≈295 that rate-caps throughput.
type: note
topic: foundation
---

# Step 1 — Decode is memory-bandwidth-bound (the roofline)

> [!abstract] The big idea
> Generating one token forces the GPU to drag *every* weight out of HBM while doing almost no math, so the chip sits ~99% idle on compute. That means you can push a few hundred extra tokens (from other requests via **batching**, or guessed tokens via **speculation**) through that *same one-time weight read* almost for free — until you hit the compute roofline at a batch of ~300. **This one fact is the foundation of the entire course.**

Index: [[00 - Course Index]] · Folder: [[moc - Inference]]

---

## 1. The two clocks

To generate one token, the model multiplies the hidden state through **every weight matrix**, so the GPU must **read all $N$ parameters out of memory once per token**. A decode step is two clocks running in parallel; wall-time is the **slower** one:

$$t_\text{mem} = \frac{\text{bytes read}}{\text{bandwidth}}, \qquad t_\text{cmp} = \frac{\text{FLOPs}}{\text{peak FLOP rate}}$$

$$t_\text{token} = \max\!\left(t_\text{mem},\; t_\text{cmp}\right)$$

## 2. Worked example — Llama-70B, FP16, one H100

- weights to read $= 70\text{e}9 \times 2\ \text{bytes} = 140\ \text{GB}$
- math to do $= 2 \times 70\text{e}9 = 140\ \text{GFLOP}$ (2 FLOPs per weight — see §5)
- H100: HBM $3.35\ \text{TB/s}$, dense BF16 $\approx 990\ \text{TFLOPS}$

$$t_\text{mem} = \frac{140\ \text{GB}}{3.35\ \text{TB/s}} \approx 41.8\ \text{ms} \;\;(\textbf{bottleneck}), \qquad t_\text{cmp} = \frac{140\ \text{GFLOP}}{990\ \text{TFLOPS}} \approx 0.14\ \text{ms}$$

$$\frac{t_\text{mem}}{t_\text{cmp}} \approx 295\times$$

```
  one decode step, batch = 1:
    read weights |##########################################| 41.8 ms
    do the math  |#......................idle.............. |  0.14 ms
                  ^----------- 295x of empty compute -------^
```

The GPU spends **99.7% of the step waiting for bytes**. This is what **"decode is memory-bandwidth-bound"** means: the cost is *streaming the model out of HBM*, not the matmul.

## 3. The magic: bytes don't grow when you add tokens

Push more than one token through the same step (from other users, or guessed). Compute grows, but the **weight read does not** — each weight is read once and reused across every token in the pass:

```
                 +-------------------------------------------+
   HBM 140 GB    |  W1  W2  W3  ...  WL   (read ONCE, 41.8ms) |
                 +-----+------+------+-----------------------+
                       |  same weights broadcast to all tokens
        +--------------+------+------------+---------------+
        v                     v            v               v
     [token 1]           [token 2]    [token 3]   ...   [token K]
        \________________________ all ride under ONE weight read ___/

   B=1   : pay 41.8 ms -> 1 token        (truck 99% empty)
   B=8   : pay ~41.8 ms -> 8 tokens      (still basically free)
   B=300 : pay ~42 ms, FLOPs saturate    (no longer free)
```

---

## 4. Clarification A — why each weight is "2 bytes" (it's the precision)

A weight is just **a number**. Its byte cost is a *choice of numeric format*. 8 bits = 1 byte, so:

| Format | Bits | Bytes/weight | 70B model | H100 weight-read |
|---|---|---|---|---|
| FP32 | 32 | 4 | 280 GB | ~83.6 ms |
| **FP16 / BF16** | 16 | **2** | **140 GB** | **~41.8 ms** |
| FP8 | 8 | 1 | 70 GB | ~20.9 ms |
| INT4 | 4 | 0.5 | 35 GB | ~10.5 ms |

A float splits its bits into **sign · exponent (range) · mantissa (precision)**:

```
 FP32  S|EEEEEEEE|MMMMMMMMMMMMMMMMMMMMMMM   1+8+23  (huge range, fine precision)
 FP16  S|EEEEE|MMMMMMMMMM                   1+5+10  (small range, ok precision)
 BF16  S|EEEEEEEE|MMMMMMM                   1+8+7   (FP32 range, coarse precision)
 FP8   S|EEEE|MMM  (E4M3)                   1+4+3
        ^    ^
        |    +-- mantissa = significant digits
        +------- exponent = how big/small the number can be
```

**BF16** is the ML favorite: dynamic *range* matters more than mantissa precision in deep learning, so it keeps FP32's 8 exponent bits and sacrifices mantissa.

> [!tip] Punchline
> The bottleneck is *bytes read*, and the format directly sets that. So **quantization is a direct attack on the decode bottleneck** — it doesn't make the math cheaper (math was already free), it makes the weight sweep shorter. On the 70B model: FP16 $140\ \text{GB}\to 41.8\ \text{ms}$; FP8 $70\ \text{GB}\to 20.9\ \text{ms}$ (≈2× faster decode); INT4 $35\ \text{GB}\to 10.5\ \text{ms}$.

---

## 5. Clarification B — why each weight is "2 FLOPs" (the MAC)

**FLOP = one Floating-Point OPeration** (one $\times$ or one $+$). A layer's core job is **matrix $\times$ vector**; each output is a **dot product** of a row of $W$ with $x$:

```
          [ w11 w12 w13 ]   [ x1 ]   [ y1 ]
          [ w21 w22 w23 ] . [ x2 ] = [ y2 ]
          [-------------]   [ x3 ]   [----]

   y1 = w11*x1 + w12*x2 + w13*x3
        \ mul / \ mul / \ mul /     <- 1 multiply per weight
              \-+--/ \--+-/          <- then accumulate
```

Each term $w_{ij}\,x_j$ is **one multiply** then **one add** into the running sum — the **MAC (Multiply-ACcumulate)**, the atom of all neural-net compute (tensor cores *are* MAC arrays):

$$\text{MAC:}\quad \text{sum} \leftarrow \text{sum} + \underbrace{w_{ij}}_{}\cdot\underbrace{x_j}_{}, \qquad 1\ \text{MAC} = 2\ \text{FLOPs}$$

Exactly **one MAC per weight** (each weight is used once in its dot product), so a layer with $W$ weights does $2W$ FLOPs, and the whole model:

$$\text{FLOPs per token} \approx 2N \quad(\times B \text{ for a batch})$$

2×3 example: 6 weights → 6 mul + 6 add = 12 FLOPs $= 2 \times 6$ ✓
*(Pedant's note: a length-$k$ dot product is $2k-1$ FLOPs; everyone rounds the $-1$ away → "2 FLOPs/weight, $2N$/token.")*

---

## 6. Clarification C — where "~300" comes from (the ridge & rate-capping)

Write the two clocks as **functions of batch $B$**:

$$t_\text{mem}(B) = \frac{N w}{\text{BW}}\ \ (\textbf{flat in } B,\ \text{weights read once}), \qquad t_\text{cmp}(B) = \frac{2 N B}{\text{PEAK}}\ \ (\textbf{rises with } B)$$

They cross at $B^*$. Set them equal and solve (the $N$ cancels!):

$$\frac{N w}{\text{BW}} = \frac{2 N B^*}{\text{PEAK}} \;\;\Longrightarrow\;\; \boxed{\,B^* = \frac{w}{2}\cdot\frac{\text{PEAK}}{\text{BW}}\,}$$

For FP16 ($w = 2$) this simplifies, and the budget is **independent of model size**:

$$B^* = \frac{\text{PEAK}}{\text{BW}} = \frac{990\ \text{TFLOPS}}{3.35\ \text{TB/s}} \approx 295 \quad(\text{the ``\textasciitilde 300''})$$

```
   time
   per   ^                                  compute_time = 2NB/PEAK
   step  |                                /  (rises with B)
  41.8ms +-------------------------------X----------  memory_time (flat)
         |   memory-bound (FREE tokens)  /|   compute-bound (token_time ~ B)
         |   token_time ~ constant      / |
         +------------------------------+-+--------------->  batch B
         B=1     8     32             B*~295
```

> [!note] Intuition — "295 FLOPs per byte"
> The ridge $\frac{\text{PEAK}}{\text{BW}} \approx 295$ means *the H100 does ~295 FLOPs in the time it reads 1 byte*. Decode supplies the chip with **arithmetic intensity** $\text{AI} = \frac{2B}{w} \approx B$ FLOP/byte (FP16). So you must stack ~295 tokens to keep the compute fed.

$$\text{AI}(B) = \frac{\text{FLOPs}}{\text{bytes}} = \frac{2NB}{Nw} = \frac{2B}{w} \quad(\text{FP16} \approx B\ \text{FLOP/byte}), \qquad \text{ridge} = \frac{\text{PEAK}}{\text{BW}}$$

```
   hardware wants 295 FLOP/byte:
       B=1   ->   1 FLOP/byte   .                       (starved 295:1, idle 99.7%)
       B=32  ->  32 FLOP/byte   ###                     (still free)
       B=295 -> 295 FLOP/byte   #####################   FED  <- ridge
       B=600 -> over-supplied   -> now waiting on COMPUTE (no longer free)
```

Throughput view (the payoff) — climbs linearly while free, then **caps**:

```
   tok/s ^                       +------------- ROOFLINE (capped)
         |                     / |  token_time ~ B  ->  tok/s constant
         |   tok/s ~ B       /   |
         |  (each free)     /    |
         +-----------------+-----+---------->  batch B
                        B*~295
```

> [!warning] Honesty caveat
> $t_\text{mem}$ is only flat if weights are the *only* bytes. Real serving also streams the **KV cache**, whose bytes grow with $B \times \text{context}$. So the real line tilts up, the crossover comes earlier, and production throughput typically knees around **batch ~32**, not 295. The 295 is the clean weights-only *ceiling* (the principle), not the measured number.

---

## 7. The B200 check question (and its answer)

> [!question] Check
> B200 has ~2.4× the bandwidth of H100 (8 vs 3.35 TB/s). Does that give ~2.4× more *free tokens*?

> [!success] Answer — No
> $B^* = \frac{\text{PEAK}}{\text{BW}}$ has bandwidth in the *denominator* but FLOPs in the *numerator*, and B200 scaled **both together**:
> $$\text{H100: } \frac{990}{3.35} \approx 295, \qquad \text{B200: } \frac{2250}{8.0} \approx 281 \;\;(\text{same budget})$$
> What B200 buys is a **faster trip, not a bigger truck**: every weight-sweep is ~2.4× quicker ($t_\text{mem}: 41.8 \to 17.5\ \text{ms}$) → ~2.4× more absolute tok/s, same ~300 capacity. To *widen* the free budget you must change the **FLOP:byte ratio** (e.g. quantize to FP8 — half the bytes, and FP8 ~doubles PEAK, pushing the ridge to ~560–590), not just add bandwidth. **The lever is the ratio, not bandwidth alone.**

---

## Key formulas

$$\text{bytes/token} \approx N w \qquad \text{FLOPs/token} \approx 2 N B$$

$$t_\text{token} = \max\!\left(\frac{N w}{\text{BW}},\ \frac{2 N B}{\text{PEAK}}\right)$$

$$\text{AI} = \frac{2B}{w}\ (\approx B \text{ in FP16}) \qquad \text{ridge} = \frac{\text{PEAK}}{\text{BW}} \approx 295\ \text{(H100, BF16)}$$

$$\text{memory-bound} \iff \text{AI} < \text{ridge} \qquad B^* = \frac{w}{2}\cdot\frac{\text{PEAK}}{\text{BW}} \approx 295\ \text{(FP16, H100)}$$

## Things to understand (checklist)

- [ ] Decode = streaming all weights from HBM; the matmul is nearly free.
- [ ] $t_\text{token} = \max(t_\text{mem}, t_\text{cmp})$; at $B=1$ memory wins ~295×.
- [ ] Bytes (weight read) are **fixed** w.r.t. token-count → extra tokens ride free.
- [ ] "2 bytes/weight" = FP16/BF16; precision sets the bottleneck → quantization = #1 latency lever.
- [ ] "2 FLOPs/weight" = one multiply-accumulate (MAC) per weight → $\approx 2N$/token.
- [ ] $B^* = \frac{w}{2}\frac{\text{PEAK}}{\text{BW}} \approx 295$ (FP16); it's the FLOP:byte machine balance, not model size.
- [ ] More bandwidth = faster trip; more free tokens needs a changed FLOP:byte ratio.
- [ ] Real knee ~batch 32 because the KV cache adds $B \times \text{context}$ bytes.

## The analogy

A **cross-town delivery truck**: driving it across the city (reading all the weights) takes 40 min and burns the fuel whether empty or full; tossing in a parcel (computing a token) takes seconds. Delivering one parcel per trip is absurd — load ~300 before it's physically full (the roofline) without lengthening the trip. **Batching** = parcels from many customers (throughput); **speculation** = one customer's assistant pre-guessing their next 8 parcels (latency). A B200 = same ~300-parcel truck, driving 2.4× faster.

## Where this leads

The fixed-cost weight sweep makes a slab of free compute. Fill it along two orthogonal axes:
- **Batch axis** → many requests → **continuous batching** (Step 2, throughput).
- **Sequence axis** → guessed future tokens of one request → **speculative decoding** (Steps 3+, latency) — where DSpark's story begins.
