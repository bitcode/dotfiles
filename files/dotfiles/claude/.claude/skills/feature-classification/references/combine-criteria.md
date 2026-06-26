# Stage 3 Combine-Criteria — C0-C15 (VETTED-T2 → SELECTED)

_Source: Cat 42 §S3.7 + patches (C0, C8-C15). Per-COMBINATION checklist. Decides which 3-8 vetted
features to combine and send to backtest. NOT the same as the Stage-2 G-gate, NOT the Stage-6
DSR/PBO certification._

| # | Criterion | Threshold | Gate | Source |
|---|---|---|---|---|
| **C0** | Axis diversity | selected set spans ≥ 3 of 6 axes (by CLUSTER, not label) | hard | patch |
| **C1** | Orthogonality | all pairs `\|r\| < 0.7`; no per-regime cluster collapse | hard | `36 §2.12,2.13` |
| **C2** | Each carries info | each feature passed G1-G18 (`\|IC\|≥0.02`, ICIR≥0.3) | hard | `36 §2.4,2.20` |
| **C3** | Complementarity | ≥1 pair anti-correlated IC across regimes | soft | `36 §2.13` |
| **C4** | Theoretical grounding | one-sentence economic/microstructure rationale | hard | `why-bt-fail §8b` |
| **C5** | Net-of-cost edge | gross > cost floor (full check Stage 5; FLOOR_SR=−0.0951) | hard@S5 | S0.1 |
| **C6** | Not overfit | selection on train only; backtest held-out (full Stage 6) | hard@S6 | §S3.8 |
| **C7** | Enough samples | EPP = n_events/n_params ≥ 20; n_trades ≥ 30 | hard | S0.3 |
| **C8** | Interaction synergy | ≥1 pair interaction IC > sum of individual ICs | soft | S3.12 |
| **C9** | Conditional importance (MDA) | each MDA > 0; reject if MDA < 0 (HARMFUL) | hard | `36 §2.23` |
| **C10** | Conditional MI | `MI(f_i; y \| S_-i) > ε` (reject if ≈0) | hard | S3.6 |
| **C11** | Execution feasibility | no INFEASIBLE in primary path; MARGINAL → CONFIRMER/GATE | hard | S2.11 |
| **C12** | Turnover-adjusted IC | `IC_net = IC_gross − turnover·C_RT/σ > 0` each | soft | S0.1 |
| **C13** | Regime robustness | ≥1 feature has N_positive ≥ 3 regimes (IC_k>0.02) | soft | S2.6 |
| **C14** | Crowding balance | ≥2 features LOW crowding; ≤1 HIGH | soft | S2.12 |
| **C15** | Distributional stability | all PSI < 0.20 (else adaptive-norm / regime-gate) | soft | `36 §2.6` |

## Application order (Cat 42 §S3.7 — do NOT skip to C5 with un-vetted features)

```
C2 (each predicts) → C0 (axis diversity, BY CLUSTER) → C1 (orthogonal pairwise) → C4 (grounded)
  → C11 (execution feasible) → C12 (turnover-adj IC positive)
  → BUILD the combo
  → C8 (synergy — if detected, switch to nonlinear fusion in Stage 4)
  → C9/C10 (conditional importance / MI in the set)
  → C5/C6/C7 (the combo certifies — Stages 5-6)
  → C13/C14/C15 (robustness / crowding / stability — final ranking preferences)
```

## Key distinctions (do not confuse)

- **C1 (orthogonality) vs C3 (complementarity):** C1 = uncorrelated returns. C3 = anti-correlated
  *errors*, correlated *profits* (one strong in Expansion, other in Crisis). Subtler, more powerful.
- **C0 is BY CLUSTER, not label.** This is the criterion that the axis-label trap defeats: a set
  spanning 3 axis *labels* but only 2 correlation *clusters* does NOT satisfy C0. Compute clusters
  first (`selection-methods.md` / `axis-and-clusters.md`), then count effective axes.
- **C9 (MDA) is the conditional version of C2.** A feature can pass C2 (univariate IC) but fail C9
  if another selected feature already captures its info (nonlinear redundancy C1's linear |r| misses).
- **C12 is the feature-level version of C5.** C13 ≠ C3: C13 = ≥1 feature works in MANY regimes; C3
  = features work in DIFFERENT regimes.
- **C4 defends against the False Strategy Theorem.** One stated hypothesis = one trial; grid-search
  of 1000 pairs = 1000 trials. Every combination *considered* is a trial for the DSR deflation.

## How to run it

`qpm.manifest.criteria.evaluate(combination, manifest, corr=...)` returns per-criterion verdicts
(PASS/FAIL/None=pending). Criteria needing data not yet available return None (pending) — NEVER a
silent pass. `combo.is_selectable()` = all hard gates evaluable and passing.
