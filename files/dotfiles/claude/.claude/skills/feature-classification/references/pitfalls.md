# Pitfalls — documented failure modes + the ones WE hit

_The corpus anti-patterns (Cat 42 §S0.6) PLUS the measurement traps this project actually fell
into. Read before vetting/selecting. Each has a one-line guard._

## Corpus anti-patterns (AP-1..AP-11)

- **AP-1 Grading features as strategies.** Features go to Tier 2 (carries info?), NOT Tier 4
  (tradeable standalone?). A feature failing Tier 4 is not a failure — it's a FUSION_FEATURE.
- **AP-2 Forcing single-feature backtests.** The deliverable is a COMBINATION, not a hero signal.
- **AP-3 The 146-D monster.** Target 3-8 features, not 146. Dimensional cap √K (K=4 → max 2×).
- **AP-4 Pooled IC without regime conditioning.** Compute per-regime IC (a feature +0.05 in
  Expansion / −0.05 in Crisis has pooled IC ~0 — looks dead, isn't).
- **AP-5 Pooling across bar frames.** QB-1/QB-5/QB-9 are separate strategies. Never pool. Every
  number is meaningless without its frame.
- **AP-6 Unregistered trials.** Every feature/combo LOOKED AT is a trial for the DSR. Count them.
- **AP-7 Leakage.** Purge + embargo + global bar index. SR>2 = leakage until proven otherwise.
- **AP-8 Bracket-grid curve-fitting.** Small pre-registered bracket grid only.
- **AP-9 Missing-regime certification.** Every regime needs ≥50 events or its weights are excluded.
- **AP-10 Too-good-to-be-true.** SR>2 / IC>~0.15 on range bars = treat as artifact until proven.
- **AP-11 Selection = optimization done at once.** Select (which) and optimize (weights) must be
  sequential. Doing both at once (logistic on all features) overfits (PBO 0.667).

## The measurement traps WE hit (project-specific, hard-won)

### T1 — Range-bar IC inflation (the biggest one)
Raw IC of any DIRECTION-TRACKING feature on QuantBars is inflated by the mechanical range-bar
autocorrelation (each bar is ±range by construction → bar returns autocorrelate, lag-1 ACF ≈ +0.16).
A regime feature scored raw IC@5 = +0.39 but a TRIVIAL last-bar-sign baseline scored +0.34 on the
same bars (the feature correlated 0.95 with it). After controlling, real IC was +0.065.
**Guard:** on range bars use PARTIAL IC (residualize feature + forward-return on last-bar-sign).
Raw IC ≥ ~0.15 on QB-1 is suspect until partial IC confirms. Better: vet on DOLLAR bars (near-IID,
lag-1 ACF +0.002) where raw IC is honest. Vet on BOTH clocks; a feature must survive the IID clock.

### T2 — Pearson IC on heavy-tailed L3 features
L3 order-flow features are extremely heavy-tailed (kurtosis can be >20,000 — a few bars with huge
spikes). Pearson IC is destroyed by the tails (showed 0.003 when the real monotone relationship was
strong). **Guard:** use RANK (Spearman) IC for L3/microstructure features — the corpus default.
G7's heavy-tail flag (kurtosis>5) is the trigger to switch metric / normalize (Cat 37).

### T3 — Pooled IC vs per-day IC
Concatenating all days then computing one IC inflates ~50x via cross-day level structure (a feature
showed pooled rank IC 0.32 but per-day mean rank IC 0.006). **Guard:** the honest headline is the
PER-DAY mean rank IC + its cross-day ICIR/t-stat, NEVER the cross-day-pooled IC.

### T4 — Mono-axis pool / mining one axis
Vetting batch after batch from the SAME axis (e.g. all Order-Flow) produces a pool that can't
satisfy C0 (≥3 axes) and is full of near-duplicates. **Guard:** vet deliberately ACROSS the 6 axes;
after each batch check axis (cluster) coverage, not feature count.

### T5 — Axis LABEL ≠ independent breadth (the deepest one)
A pool "spanning 4 axes" collapsed to 2 correlation clusters: cvd (Order-Flow) / sess-open-range
(Time) / vwap-dev-z (Structure) all correlated 0.60-0.76 — three labels, ONE bet. Per-feature G5
(pairwise <0.85) passed each individually but missed the cluster. **Guard:** the real axis is the
CORRELATION CLUSTER. Always cluster the vetted pool (HRP/ONC) and pick ONE per cluster; report
effective-N = #clusters. C0 is evaluated on clusters, not labels. (`axis-and-clusters.md`.)

### T6 — Marking a feature MEASURED off IC alone
Earlier features were marked vetted having checked only IC/ICIR — skipping the full G1-G18 (MI,
day-stability, distribution shape, execution feasibility, redundancy). **Guard:** a feature is only
VETTED-T2 after the COMPLETE graduation gate runs and all REQUIRED gates pass.

### T7 — Validated-elsewhere ≠ validated-here
The corpus's "Pull +1.4-2.9t validated" edge was measured in event-time windows, not QB/dollar-bar
forward-return IC at our horizons — where pull is too sparse (1.4% active) to clear the sample gate.
**Guard:** a corpus "VALIDATED" tag is a prior, not a pass. Re-vet every feature on OUR clock/horizon/
instrument; record the verdict honestly even when it contradicts the corpus.

## The meta-guard

When tempted to declare a feature good or a combination ready, ask: which exact gate (G# or C#) am I
asserting passed, on which clock, with which IC metric (rank? partial? per-day?), and is the
"breadth" real clusters or just labels? If you can't answer all of those from a computed result,
it's not vetted — it's hand-waved.
