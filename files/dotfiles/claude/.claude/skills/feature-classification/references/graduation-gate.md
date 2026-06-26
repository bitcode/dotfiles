# Stage 2 Graduation Gate — G1-G18 (UNTESTED → VETTED-T2)

_Source: Cat 42 §S2.8 + patches §S2.9-S2.13/§G14-G18. Per-FEATURE gate. All REQUIRED must pass
(fail any → REJECTED, not in selection pool). RECOMMENDED are flags, not auto-rejects. CONTEXTUAL
depends on role-intent._

Graduation means the feature carries independent, stable, non-redundant information and is allowed
into a combination. It does NOT mean tradeable (that's Stage 5-6, a separate harder test).

| # | Criterion | Class | Threshold | Source |
|---|---|---|---|---|
| **G1** | IC predicts | REQUIRED | `\|IC\| ≥ 0.02` at ≥ one horizon | `36 §2.4` |
| **G2** | ICIR consistent | REQUIRED | `\|ICIR\| ≥ 0.3` | `36 §2.20` |
| **G3** | Not noise | REQUIRED | MI > 0.02 OR `\|IC\| ≥ 0.02` | `36 §2.8,2.4` |
| **G4** | Day-stability | REQUIRED | StdIC < 0.15 AND no SIGN-FLIP | `36 §2.14` |
| **G5** | Not redundant | REQUIRED | `\|r\| < 0.85` vs all existing features | `36 §2.12` |
| **G6** | Half-life classified | REQUIRED | valid class (not `noise`) | `36 §2.11` |
| **G7** | Distributional shape known | REQUIRED | skew/kurt/JB computed | `36 §2.9` |
| **G8** | Axis assigned | REQUIRED | one of 6 axes | §A3 |
| **G9** | Role-intent decided | REQUIRED | FUSION/CONFIRMER/GATE/STANDALONE | §I3 |
| **G10** | Decile lift present | RECOMMENDED | `\|L/S\|` spread > 0 AND monotonicity `\|ρ\| ≥ 0.4` | `ic_sweep.py:243` |
| **G11** | Per-regime IC computed | RECOMMENDED | computed for all available regimes | `36 §2.13` |
| **G12** | Incremental lift > 0.10 | RECOMMENDED | adds > 0.10 OOS vs existing fusion | `why-bt-fail §4` |
| **G13** | Cost-floor check | CONTEXTUAL | if gross move < cost floor → role forced FUSION_FEATURE | S0.1 |
| **G14** | Execution feasibility | **REQUIRED** | `τ_decay > τ_execution` OR role → CONFIRMER/GATE on coarser frame | S2.11 |
| **G15** | Parameter robustness | RECOMMENDED | Robustness Index > 0.4 (not FRAGILE) | S2.9 |
| **G16** | Data perturbation stability | RECOMMENDED | IC degradation < 0.30 under 1% noise | S2.10 |
| **G17** | IC trend | RECOMMENDED | not DYING (IC_late ≥ 0.02 OR trend p > 0.05) | S2.13 |
| **G18** | Crowding risk assessed | RECOMMENDED | tag assigned (LOW/MEDIUM/HIGH) | S2.12 |

## Detail on the non-obvious gates

- **G3 MI:** binned mutual information (10×10, Laplace-smoothed). MI>0.05 & |r|≥0.1 = LINEAR
  predictor; MI>0.05 & |r|<0.1 = NON-LINEAR predictor; MI>0.02 = weak; else noise.
- **G4 SIGN-FLIP** (the dangerous instability): `min_d IC_d < −0.05 AND max_d IC_d > +0.05` — the
  feature predicts opposite directions on different days. Hard reject (must regime-gate to use).
- **G5 redundancy:** the per-feature gate is |r|<0.85 (REDUNDANT above). Vet strongest-IC-first so
  a later feature redundant with an already-graduated stronger one is the one rejected
  ("pick-one-per-cluster" at vetting time). NOTE: this is the PAIRWISE gate; the *cluster*-level
  redundancy (a group all at r 0.6-0.76) is caught at Stage-3 selection via clustering — see
  `axis-and-clusters.md`. Pairwise G5 alone does NOT prevent a correlated cluster.
- **G7 distributional shape:** Fisher skew, excess kurtosis g₂, JB = (n/6)(g₁²+g₂²/4); reject
  normality if JB>5.991. **Heavy-tail flag if g₂>5.0 → use rank IC / normalize before linear fusion.**
- **G14 execution feasibility (REQUIRED — physics, not statistics):** `τ_decay = half-life(bars) ×
  avg_bar_seconds` vs `τ_execution ≈ 50-200ms` (NT8). Capture ratio R=τ_decay/τ_execution: >10
  FEASIBLE / 1-10 MARGINAL / <1 INFEASIBLE. INFEASIBLE may still graduate if role downgraded to
  CONFIRMER/GATE on a coarser frame.

## How to run it

`qpm.research.graduation.grade(...)` → `GraduationResult` with per-gate verdict (PASS/FAIL/None=
pending) and `required_failures`. `graduated` = all REQUIRED-hard gates evaluable and none failed.

**Honest-measurement requirements (see `pitfalls.md` — these change the inputs to G1/G2/G3):**
heavy-tailed L3 features → rank (Spearman) IC; report per-day mean rank IC (not pooled); on range
bars use partial IC (control last-bar-sign). These are not optional — the wrong metric flips verdicts.
