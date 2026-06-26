# Stage 3 Selection Methods — which 3-8 features to combine

_Source: Cat 42 §S3.1-S3.6. Given M VETTED-T2 features, pick subset S (|S| ∈ [2,8]) maximizing
ensemble Sharpe. C(M,N) is huge (C(30,5)=142,506) → use clustering/filter (no per-subset backtest),
wrappers only to fine-tune._

## The PRIMARY method: HRP hierarchical clustering / ONC (pick-one-per-cluster) — §S3.5

This is THE recommended method and the one whose absence caused the axis-label drift. 4 steps:

1. **Correlation distance matrix:** `d_ij = √((1 − r_ij)/2)`. (r=1→d=0, r=0→d≈0.707, r=−1→d=1.)
   Use rank/Spearman r for heavy-tailed features. Use Ledoit-Wolf shrinkage if n_eff < M.
2. **Hierarchical clustering** (agglomerative, Ward or single linkage) on d → dendrogram.
3. **Cut the dendrogram (choose K):**
   - **ONC** (Optimal Number of Clusters, AFML Ch.8): pick K maximizing silhouette score
     (within-cluster similarity vs between-cluster dissimilarity). Data-driven — preferred.
   - or fixed K (e.g. 6 for 6 axes), or distance threshold (cut at d≈0.5 ≈ r≈0.5).
   - Target K ∈ [3,8]. If K>8: raise threshold / enforce 6-axis cap. If K<3: lower threshold / add
     from under-represented clusters.
4. **Pick one representative per cluster** = the feature with highest `|ICIR|` (or highest IC, or
   lowest within-cluster avg correlation). **Effective-N = number of clusters.**

**Why clustering beats pairwise thresholding (G5/C1):** pairwise only sees pairs — features A,B,C
all at r≈0.6 (each below 0.85) pass G5 individually but are collectively one bet. Clustering groups
them and selects ONE representative. This is the fix for "labels ≠ breadth."

## Filter method (fast first pass) — §S3.2

Rank by a univariate metric (IC, ICIR, MI, decile-lift), select top-K. Fast O(M), no selection
overfitting, but ignores collinearity (two high-IC features at r=0.9 both selected). **Use only as
a first pass + axis-coverage constraint, then hand to clustering.** Pitfall: top-K by IC
over-represents the axis with the most features — always enforce cluster/axis coverage.

## mRMR (cross-check) — §S3.6

Maximize relevance, minimize redundancy. `mRMR(C) = MI(C;y) − (1/|S|)Σ_j MI(C;X_j)`; greedy add
the feature maximizing `D_i − R_i` (or `D_i/(R_i+ε)`). Uses MI (nonlinear). Use as a cross-check
on clustering — if they diverge, mRMR may catch conditional-MI complementarity clustering misses.

## Embedded (cross-check) — §S3.4

LASSO (L1 → exact zeros), Elastic Net (L1+L2, stable with correlated features), tree importance.
For strategy construction use a LARGER λ than CV-optimal (want sparse 3-8, not the 20-50 CV picks).
Cross-check only — LASSO arbitrarily picks one of correlated pair (unstable).

## Wrappers (fine-tune ONLY) — §S3.3

Forward/backward/RFE/SFFS with backtest as the criterion. **Most overfitting-prone** (each backtest
is a trial; 142k subsets → expected max Sharpe from noise > 2.0). Use only after clustering
pre-selects candidates, always with purged CV, always counting trials for the DSR.

## When-to-use summary

| Method | Role |
|---|---|
| Filter | fast first pass + coverage; never alone |
| **HRP clustering / ONC** | **PRIMARY** — orthogonal selection without per-subset backtest |
| mRMR | cross-check (conditional complementarity) |
| LASSO/ElasticNet | cross-check |
| Wrappers | fine-tune only, after clustering, with purged CV |

## Selection bias / trial accounting (§S3.8)

Run Stages 2-3 on a SELECTION (train) set only; lock S; run Stages 5-6 on a HELD-OUT set. Every
subset tried = a trial for the DSR deflation (5 subsets via clustering/mRMR/LASSO = 5 trials).
Feature *vetting* also counts: vet 72, select 5 → N=77 trials, deflate by 77 not 5. Effective N via
ONC on the feature-correlation matrix (correlated features aren't independent trials).

## Selection ≠ optimization (§S3.10)

Select (WHICH features, S3) and optimize weights (HOW MUCH, S4) must be SEQUENTIAL, never
simultaneous. The 146-D engine did both at once (logistic on 146 features) → PBO 0.667. Two-step:
select 3-8 using only correlation structure + individual ICs (no backtest), THEN optimize weights
on the locked set.
