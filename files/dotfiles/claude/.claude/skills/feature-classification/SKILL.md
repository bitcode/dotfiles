---
name: feature-classification
description: The QPM discipline for classifying, vetting, and selecting trading features (Stages 1-3 of the Cat 42 pipeline). Use whenever evaluating a feature or choosing a combination of features — tag it on the 19-field schema, run the G1-G18 graduation gate, cluster the vetted pool (axis = correlation cluster, NOT label), and pick one representative per cluster before applying the C0-C15 combine-criteria. Prevents the documented failure modes (mono-axis pools, range-bar IC inflation, treating labels as independent breadth). Faithful to $HOME\quantResearcher.
allowed-tools: Bash Read Write Edit Glob Grep
---

# Feature Classification & Selection (QPM, Stages 1-3)

This skill is the **single authoritative discipline** for turning a raw feature into a vetted,
selected fusion input. It exists because feature classification IS the project, and doing it
ad-hoc (re-deciding criteria per batch) caused real drift: mono-axis pools, the wrong IC metric
on heavy-tailed features, and treating axis *labels* as independent breadth. Every feature and
every combination is judged by the SAME corpus-faithful criteria, computed (never eyeballed),
with `qpm/manifest/manifest.json` as the system of record.

**Source of truth:** `$HOME\quantResearcher` (Cat 42, Cat 36, the feature-selection-
criteria catalog, the feature-master-manifest). The `references/` here are the distilled, exact
spec; when in doubt, the corpus wins — re-read it.

## The two criteria sets — NEVER conflate

| Set | Stage | Unit | Transition | Spec |
|---|---|---|---|---|
| **G1-G18** | Stage 2 | one feature | UNTESTED → VETTED-T2 | `references/graduation-gate.md` |
| **C0-C15** | Stage 3 | a combination | VETTED-T2 → SELECTED | `references/combine-criteria.md` |

A feature graduates (G) to be *allowed into* a combination. A combination is *selected* (C) to be
backtested. Graduation ≠ tradeable; selection ≠ certified. (Stages 4-6 are out of scope here.)

## The workflow

### Stage 1 — Characterize (tag the feature)
Assign the 19-tag schema (`references/classification-schema.md`). The load-bearing tags to get
right first: **axis** (1 of 6), **half-life class**, **role-intent** (default FUSION_FEATURE),
**data-dependency**, **crowding-risk**. Axis is assigned by formula first, then confirmed by the
correlation matrix (axis = cluster — see below).

### Stage 2 — Vet (the G1-G18 graduation gate)
Run `scripts/vet.py` (or `qpm.research.graduation.grade`). It measures IC/ICIR/MI/day-stability/
half-life/distribution-shape/execution-feasibility and returns VETTED-T2 or REJECTED + the exact
gates failed. **Honest-measurement rules (non-negotiable, from `references/pitfalls.md`):**
- **Heavy-tailed L3 features → RANK IC (Spearman), not Pearson.** Pearson is destroyed by the
  tails (kurtosis can be >20,000). The corpus default for microstructure features is Spearman.
- **Report PER-DAY mean rank IC, not cross-day-pooled IC.** Pooled IC inflates ~50x via cross-day
  level structure; the honest edge is the per-day measure.
- **On range bars (QuantBars), use PARTIAL IC** (control for last-bar-sign) — raw IC is inflated
  by mechanical autocorrelation. On dollar bars (near-IID) raw IC is honest. Vet on BOTH clocks.
- Every number is bar-clock-relative. State the clock. Never pool across QB-1/QB-5/QB-9.

### Stage 3 — Select (cluster FIRST, then C0-C15)
This is the step whose absence caused the steering. **DO NOT pick features by axis label.**
1. `scripts/select.py` (or `qpm.research.cluster`): build the correlation-distance matrix
   `d=√((1−r)/2)` over the VETTED-T2 pool, hierarchically cluster, choose K by ONC (silhouette),
   and **pick one representative per cluster** (highest |ICIR|). Effective-N = number of clusters.
2. The representatives are the candidate combination. Run the **C0-C15** checklist in the specified
   application order (`references/combine-criteria.md`): C2 → C0 → C1 → C4 → C11 → C12 → build →
   C8 → C9/C10 → C5/C6/C7 → C13/C14/C15.
3. Record cluster membership + effective-N in the manifest, not just axis tags.

> **The axis-label trap (the core lesson):** the *real* axis is the correlation cluster, not the
> label. Two features labeled different axes (e.g. Order-Flow vs Structure) can correlate 0.7 and
> are ONE bet; two features labeled the same axis can be uncorrelated and are TWO bets. Breadth =
> number of clusters, not number of features or labels. (`references/axis-and-clusters.md`.)

## Quick reference — the load-bearing thresholds (full table in references/thresholds.md)

- IC bands: ≥0.05 PREDICTIVE / ≥0.02 weak-usable / <0.02 noise
- ICIR: ≥0.5 GOOD / ≥0.3 MODERATE(floor) / <0.3 UNSTABLE; t_IC = √T·ICIR > 2 significant
- Orthogonality: selection C1 |r|<0.7; vetting G5 |r|>0.85 REDUNDANT / 0.7-0.85 CONSOLIDATE
- Day-stability: StdIC<0.05 STABLE / <0.15 ok; SIGN-FLIP if min IC<−0.05 AND max IC>+0.05 (reject)
- Half-life (bars): ≤5 MICROSTRUCTURE / 5-50 TACTICAL / >50 STRUCTURAL
- PSI: <0.10 stable / >0.20 drift; regime/instrument IC range: >0.30 dependent / ≤0.15 consistent
- Small-N: 3-8 features; SR_ens=SR_avg·√(N/(1+(N−1)ρ)); ceiling 1/√ρ; cap √K (K=4 → 2×)
- C0 needs ≥3 axes (by CLUSTER); C14 needs ≥2 LOW-crowding features

## Files
- `references/` — the complete knowledge canon (schema, gates, criteria, methods, thresholds,
  axis/clusters, pitfalls). Read the relevant one before judging a feature; cite section codes.
- `scripts/vet.py` — CLI: vet feature columns on a clock → graduation table → manifest.
- `scripts/select.py` — CLI: vetted pool → cluster → pick-one-per-cluster → C0-C15 → candidate combo.
- Canonical implementation lives in the `qpm` package (`qpm.research.ic / graduation / cluster`,
  `qpm.manifest.criteria / schema`); these scripts import it. One implementation, not two.
