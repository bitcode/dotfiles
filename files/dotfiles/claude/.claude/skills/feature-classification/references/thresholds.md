# Thresholds — every load-bearing constant in one place

_Source: Cat 36 (the disposition thresholds are transcribed from real QuanthropyAuto code) + Cat 42.
When a number appears in multiple places, the stage-specific value is noted. ALL are bar-clock-relative._

## IC (Information Coefficient)
| Band | Verdict |
|---|---|
| `\|IC\| ≥ 0.05` | PREDICTIVE (Cat 36 §2.4 vetting band) |
| `\|IC\| ≥ 0.02` | weak signal — usable as fusion input (G1/C2 floor) |
| `< 0.02` | noise — reject |
| `\|IC₁\| < 0.01` | pre-rejected as noise at characterization |

Realistic single-feature IC = 0.02-0.05 (corpus). IC significance: `\|IC\|·√n_eff > 1.96`; for
IC=0.03 need n_eff > ~4,268. Decay flags: |IC₅|/|IC₁|<0.3 FAST-DECAY; >1.2 SLOW-DECAY.

## ICIR
| Band | Verdict |
|---|---|
| `\|ICIR\| ≥ 0.5` | GOOD |
| `\|ICIR\| ≥ 0.3` | MODERATE (the G2 floor) |
| `< 0.3` | UNSTABLE |

`t_IC = √T · ICIR`; `t_IC > 2` significant at 95%. Min T ≥ 30 periods.

## Orthogonality / correlation (|r|)  — STAGE-DEPENDENT
| `\|r\|` | Vetting (G5) | Selection (C1) |
|---|---|---|
| > 0.85 | REDUNDANT — drop one | (fails) |
| 0.7 - 0.85 | CONSOLIDATE — keep higher IC | (fails C1's <0.7) |
| < 0.7 | OK | OK |

G5 reject is |r| ≥ 0.85; C1 select gate is |r| < 0.7. Beyond Pearson: Spearman ρ, distance
correlation (dCor=0 iff independent), MI (>0.05 significant), VIF (>10 reject).

## Day-stability (Cat 36 §2.14)
StdIC < 0.05 STABLE / < 0.15 moderate (G4 floor) / ≥ 0.15 UNSTABLE.
SIGN-FLIP (hard reject): `min_d IC_d < −0.05 AND max_d IC_d > +0.05`.

## Half-life (bars)
≤ 5 MICROSTRUCTURE / 5-50 TACTICAL / > 50 STRUCTURAL. Continuous: τ½ = ln2/λ.

## Distribution drift
PSI < 0.10 stable / 0.10-0.20 slight / > 0.20 significant. KS reject at α=0.05 (crit 1.36/√n).
Confirmed drift dual-gate: PSI > 0.15 AND KS rejects.

## Distributional shape (Cat 36 §2.9)
JB > 5.991 rejects normality (χ²₂, p<0.05). Heavy-tail flag if excess kurtosis g₂ > 5.0 → use rank
IC / normalize before linear fusion.

## Regime / instrument IC range
> 0.30 DEPENDENT/SPECIFIC (must gate) / > 0.15 moderate / ≤ 0.15 consistent (universal, preferred).

## Activation
active% = 100·#{x≠0}/N; < 50% → LOW ACTIVATION flag (downweight |r| verdicts).

## Mutual information (Cat 36 §2.8)
MI>0.05 & |r|≥0.1 LINEAR / MI>0.05 & |r|<0.1 NON-LINEAR / MI>0.02 weak / else noise.

## Execution feasibility (Cat 42 S2.11)
Capture ratio R = τ_decay/τ_execution (τ_exec ≈ 50-200ms NT8). R>10 FEASIBLE / 1-10 MARGINAL / <1
INFEASIBLE. τ_decay = half-life(bars)·avg_bar_seconds.

## Small-N / diversification
N ∈ [3,8]. `SR_ens = SR_avg·√(N/(1+(N−1)ρ))`. Ceiling `1/√ρ` (ρ=0.05→4.5×, ρ=0.25→2×). Dimensional
cap `√K`, K=#instruments (K=4 → max 2× gain regardless of feature count). EPP ≥ 20; n_trades ≥ 30.

## Certification (Stage 6 — out of scope here, for reference)
DSR ≥ 0.95 · PBO ≤ 0.5 · champion_SR > FLOOR_SR (−0.0951) · ≥100 trades · WFE ≥ 0.3.
CPCV: n_blocks=6, k_test=2, embargo=500 bars.

## Selection structural
C0: ≥ 3 axes BY CLUSTER (not label). C14: ≥ 2 LOW-crowding features, ≤ 1 HIGH. Correlation distance
d = √((1−r)/2). Effective-N = number of clusters.

## Strategy-level (Stage 7 — reference)
|ρ_strategy_returns| < 0.5 combinable / < 0.3 ideal / > 0.7 same bet. (Measured on RETURNS, not
features — orthogonal features can still produce correlated strategy returns if they fire together.)
