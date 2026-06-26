# Axis = Correlation Cluster (NOT label) + the small-N math

_Source: Cat 42 §A1-A6, §N1-N3. This is the conceptual core — the lesson that "combine across axes"
only works if the axis is the CORRELATION CLUSTER, not the label you wrote on the feature._

## The single most important organizational concept

An **axis** = one independent dimension of market information. Features on the same axis are
correlated (same thing, different math); features on different axes are orthogonal. **You combine
ACROSS axes, not within.** (§A1, §A2.)

BUT — the axis LABEL is only a hypothesis. The REAL axis is determined by the **correlation matrix**
(§A3 step 2, §A4): "Compute the correlation matrix... Cluster them. Features in the same cluster are
on the same axis." So:
- Two features labeled DIFFERENT axes (e.g. Order-Flow `cvd` vs Structure `vwap-dev-z`) that
  correlate r=0.70 are in the SAME cluster → ONE bet, not two.
- Two features labeled the SAME axis (e.g. Order-Flow `cvd` vs Order-Flow `ofi`) that correlate
  r=0.02 are in DIFFERENT clusters → TWO real bets.

**Breadth = number of clusters, not number of features and not number of axis labels.** This is the
exact trap that produced a pool "spanning 4 axes" that was really 2 clusters. C0 (≥3 axes) must be
evaluated on clusters; selection picks ONE representative per cluster (`selection-methods.md` §S3.5).

> **Clusters are CLOCK-CONDITIONAL (see `clocks.md` / Cat 43 §43.12).** The correlation matrix — and
> therefore which features are one bet vs two — DEPENDS on the bar clock (semantic convergence,
> §43.11). Verified: ropes/macd/obos are mutually r 0.6–0.74 on QB-1 (ONE bet) but ~0 on dollar (two
> bets). So build the matrix and pick representatives **ON THE CLOCK YOU INTEND TO TRADE**; a
> dollar-clock cluster map does not transfer to QB-1. Effective-N (breadth) is clock-specific —
> re-cluster per clock, never reuse another clock's selection.

## The linear-algebra mental model (§A4)

Picking features = picking a BASIS — a small set of axes that span market behavior with minimal
overlap, as close to orthogonal (perpendicular) as possible. The diversification dial is ρ:

`SR_ensemble = SR_avg · √(N / (1 + (N−1)·ρ))`

- ρ=0, N=3, each SR 0.5 → 0.5·√3 ≈ 0.87 (74% lift).
- ρ=0.9, N=3 → 0.5·√(3/2.8) ≈ 0.52 (almost no lift).
- **Same 3 features; only ρ differs. ρ is the dial that decides if combining helps at all.**

## The orthogonality gate (§A5)

| `\|r\|` | Verdict | Action |
|---|---|---|
| > 0.85 | REDUNDANT | drop one |
| 0.7 - 0.85 | CONSOLIDATE | keep higher IC; consider a blend |
| < 0.7 | OK | different enough to combine |

Caveat: orthogonality is not stationary — orthogonal overall but correlated within a regime
(re-check per regime, `36 §2.13`). And pairwise |r| misses a *cluster* of moderately-correlated
features (all at 0.6-0.76, each individually <0.85) — only clustering catches that.

## Small-N: why 3-8, not 146 (§N1-N3)

Marginal SR gain per added orthogonal signal shrinks; parameter count grows O(N²). Past ~10 you add
params faster than edge. Hard ceilings:
- **Asymptotic ceiling (Hentschel):** `lim_{N→∞} SR_ens/SR_avg = 1/√ρ`. ρ=0.05→4.5× (90% reached at
  ~28 signals); ρ=0.25→2×.
- **Dimensional cap:** when N > K (more signals than assets), returns are rank-constrained:
  `SR_ens/SR_avg = min(1/√ρ, √K)`. K=4 instruments (NQ/ES/RTY/YM) → max diversification gain √4 = 2×
  regardless of feature count. **This is why the 146-D engine could never work on 4 instruments.**
- **Empirical (Chen-Zimmermann):** 212 equity signals (ρ≈0.044) collapsed to ~19 effective.

Conclusion: deliverable = the SMALLEST combination that beats the cost floor with DSR≥0.95 — likely
2-4 signals. Start with 2; add a 3rd only if 2 doesn't clear; stop the moment it does.

## The Fundamental Law (§A6)

`IR ≈ TC · IC · √breadth`. IC = forecast↔return corr (realistic 0.02-0.05). breadth = number of
INDEPENDENT bets (= clusters × instruments × time). TC < 1 = implementation friction (cost floor
lowers it). **Qian-Hua key insight: IC volatility (σ_IC) matters more than breadth — a steady IC
0.03 (ICIR 3) beats a jumpy IC 0.06 (ICIR 0.8). Consistency > peak.** A mediocre IC with high
(genuine, independent) breadth beats a great IC with low breadth — but breadth REQUIRES independence,
which is why the cluster count, not the feature count, is what matters.
