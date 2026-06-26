# Judgement Method — role-first, measure-don't-gate

The single most important discipline in this skill. It is the antidote to the founding failure
(the regime gauge). Read this before judging *any* candidate.

---

## The core stance

> **Measure honestly. Interpret by role. Gate only the tradeable role.**

A number (IC, ICIR, correlation, hit-rate, Sharpe) is **evidence**, not a **verdict**. The verdict
depends on what the candidate is FOR. The feature pipeline's pass/fail thresholds (IC≥0.02, ICIR≥0.3,
|r|<0.7, SR>floor, DSR≥0.95, PBO≤0.5) are **calibrated for one role only — a tradeable feature/
strategy.** Applying them to a confirmer, a gate, a context gauge, a regime filter, or a display is a
category error that will either **reject a good candidate** or **accept something that then fails the
job it was actually for.** Do not inline those thresholds as universal rules. When the role is
tradeable, delegate the gating to `feature-classification` (which owns G1-G18 / C0-C15). For every
other role: measure, interpret, **report — and let the operator decide.**

---

## Step 1 — name the role (one sentence, before any measurement)

The role is the most load-bearing decision. State it explicitly. The candidate is a…

| Role | One-line definition | The question it must answer | The WRONG test for it |
|---|---|---|---|
| **Tradeable signal** | enters/exits a position on its own | does it make money net-of-cost OOS? | (none — full gate applies) |
| **Tradeable combination** | a fused score that trades | does the *blend* beat its best leg net-of-cost? | judging legs in isolation |
| **Fusion feature** | one input among several | does it add an **orthogonal axis** to the fused score? | demanding standalone tradeable edge |
| **Confirmer** | strengthens/permits another signal's entry | conditional lift **when the primary fires** | standalone directional IC |
| **Gate / regime filter** | turns trading on/off by state | does the *gated strategy's* P&L improve? | directional IC (it's direction-agnostic) |
| **Context gauge** | tells the operator how to *read* the wall | does a human read the wall **better** with it? | treating its color as buy/sell |
| **Display / HUD** | shows state, makes no edge claim | is it legible, correct, non-redundant? | any edge metric at all |

If you cannot say the role in one sentence, **stop** — that ambiguity is the regime-gauge trap. A
signal that is "kind of directional but really about regime" must be forced into one role before
measuring, because the measurement only means something *given* the role.

---

## Step 2 — measure honestly (role-independent rules)

These make the number trustworthy. They are *measurement* rules, never *gates*. Call the canonical
qpm code — do not re-implement.

| Rule | Why | Code |
|---|---|---|
| Heavy-tailed L3 → **Spearman rank IC**, not Pearson | kurtosis >20,000 destroys Pearson | `qpm.research.ic.information_coefficient(..., method="spearman")` |
| **Per-day mean**, never cross-day-pooled | pooling inflates ~50× via cross-day level structure | per-day loop, then mean |
| **State the clock; vet BOTH** (QB-1 + dollar) | a sign that flips across clocks is a range-bar artifact | run on both `D:\qpm-harvest\…_qb1_…` and `…_dollar_…` |
| Range bars → **partial IC** (control last-bar-sign); dollar → raw IC honest | QB bars are mechanically autocorrelated (lag-1 ACF ≈ +0.16) | `qpm.research.ic.partial_information_coefficient` |
| **Walk-forward** before trusting per-day-normalized signals | per-day rank-norm is mildly anticipatory (L6) | train-early / test-late split |
| **Freeze the trade sign on TRAIN** before any OOS claim | per-day sign-alignment on a low-IC signal is look-ahead (L8) | choose sign once on train, apply to test |
| Orthogonality = **realized daily-PnL correlation**, not just per-bar feature corr | per-bar r=0.31 can hide daily-PnL r=0.61 (L7) | correlate the two strategies' daily returns |
| **IC ≠ edge** — the per-trade Sharpe depends on the EXIT | a stop destroys a reversion signal (L4/L5) | judge by net-of-cost Sharpe under the *real* construction |
| Cost floor is **per-instrument & per-clock** | NQ ≈ 1.98t, ES ≈ 0.94t zero-range | `qpm.instruments.get(sym)` / `qpm.backtest.engine.round_trip_cost_ticks` |
| **Null/adversarial control** before believing a result | beats-random ≠ real if random loses to cost | `random_entry_control.py`, `adversarial_verify_*.py` |

---

## Step 3 — interpret per role (the same number, different verdicts)

Worked examples of how identical evidence reads differently by role:

**Evidence: rank-IC ≈ 0.01, ICIR ≈ 0.2, |r| ≈ 0.4 to an existing signal.**
- *Tradeable signal* → **dead.** Below any usable floor; net-of-cost it loses. Hand to
  `feature-classification`; it will (correctly) REJECT. Don't fight it.
- *Fusion feature* → **maybe.** IC is a floor not a target here; if it's a genuinely *orthogonal*
  axis (cluster-distinct), a weak-but-independent input can still lift a blend. Measure the marginal
  ΔSharpe of the blend, not the leg.
- *Confirmer* → **wrong test entirely.** Standalone IC is meaningless. Measure hit-rate of the
  *primary* signal *conditional on this confirmer agreeing* vs primary-alone. A confirmer with IC≈0
  can add real lift.
- *Context gauge* → **wrong test entirely.** It's not predicting direction. Measure whether the wall
  is more trustworthy when it's green (e.g. continuation-rate among strong-agreement bars, HIGH vs
  LOW regime) and whether a human reads better.

**Evidence: |r| = 0.6 to an existing gauge.**
- *Tradeable combination* → likely **redundant** (C1 wants |r|<0.7; near it, consolidate).
- *Confirmer / gate* → **possibly fine or even desired** — a confirmer is *supposed* to relate to the
  thing it confirms. Judge by conditional lift, not by the correlation number.

The pattern: **the role tells you which column of the evidence to read.** Reading the tradeable column
for a non-tradeable role is exactly how the regime gauge passed validation yet failed on the chart.

---

## Step 4 — gate only the tradeable role (delegate, don't inline)

- **role ∈ {tradeable signal, tradeable combination}** → invoke the **`feature-classification`** skill.
  It owns the 19-tag schema, G1-G18 graduation, HRP/ONC clustering, and C0-C15. Let it return
  VETTED/SELECTED or REJECTED + the exact failing gates. Do **not** re-derive its thresholds here.
- **every other role** → **measure + interpret + report.** Produce: the role, the honest numbers, the
  role-appropriate test result, the orthogonality picture, and a recommendation *with the operator
  making the call*. No hard reject.

This is the literal implementation of "don't hard-code judgement that rejects good options." The hard
gates exist and are correct — they're just **scoped to the one role they were built for.**

---

## The lessons (L1-L9) — guard-rails, distilled

From `qpm\LESSONS.md`. These are *measurement/construction* truths; they apply across roles.

- **L1 / AP-16:** higher IC ≠ higher net-of-cost edge. Adding a fast leg can *weaken* a combo. Judge
  by Δ(net-of-cost Sharpe), not ΔIC.
- **L2:** DSR = 1.0 is a *red flag* (trial-count laundering, or raw-N instead of effective-N as T).
  Honest certification = out-of-sample selection (walk-forward / cross-instrument).
- **L3:** within-instrument walk-forward can PASS while cross-instrument FAILS. **Direction is the
  most instrument-idiosyncratic part of a signal** — don't assume transfer.
- **L4 (Cat 42 §S4.9):** EXIT construction makes or breaks an edge. A stop destroys a contrarian/
  reversion signal (cvd-dollar: +0.03 with stop vs +0.44 timeout-only). Match exit to mechanism —
  reversion → hold-to-horizon/no-stop; momentum → stop. "Backtest rejected it" can mean "wrong exit."
- **L5:** IC/decile-spread measure *predictive content* (frictionless), NOT *tradeable edge*. Screen by
  IC, judge by per-trade net Sharpe under the real construction.
- **L6:** per-day rank-norm is mildly anticipatory → only trustworthy *through walk-forward*, never
  single-pass IC/Sharpe.
- **L7:** orthogonality is **realized daily-strategy-return** correlation, not per-bar feature
  correlation. Per-bar distinct (0.31) yet same-days (0.61) = not a diversifier. Cluster is necessary,
  not sufficient — confirm with strategy-PnL corr.
- **L8:** per-day sign-alignment on a low-IC signal is look-ahead. Freeze ONE global sign on TRAIN,
  test OOS. A "big-move edge" on an IC≈0 signal is this artifact until a frozen-sign WF proves otherwise.
- **L9:** tail-only stops (≈3-4× median move) can preserve a reversion edge where tight stops kill it.

Plus the corpus anti-patterns (AP-1..AP-11) and project traps (T1 range-bar IC inflation, T2 Pearson-
on-heavy-tails, T3 pooled IC, T4 mono-axis mining, T5 axis-label≠breadth) — full text in
`feature-classification\references\pitfalls.md`.

---

## Post-mortem: the regime gauge (the worked failure this method prevents)

What happened, mapped to the method:

1. **Role was never fixed (Step 1 skipped).** VR is a *context / trend-quality* measure — direction-
   agnostic. It was implicitly treated as "another gauge on the wall," i.e. as if directional.
2. **Measured honestly (Step 2 ✓).** The qpm work was clean: orthogonal on both clocks (|r| ≤ 0.08),
   own cluster, clock-robust sign, a real fake-reversal t-test (t=+2.47). The *measurement* wasn't the problem.
3. **Interpreted in the wrong column (Step 3 ✗).** It was accepted because it *passed feature-style
   evidence* (orthogonal, significant). But for a *context gauge* the binding test is **dashboard
   coherence** — "does a human read the wall better, does its encoding not contradict the others." That
   test was never run. Magnitude was modest (+1.8pp) and its meaning (green = quality, not buy)
   *contradicts* a wall where every other color means direction.
4. **Result on the chart:** "all over the place," never synced — because it was answering a different
   question than the wall, with an encoding that *looked* like it was answering the same one.

**The fix this method enforces:** name the role (context gauge) → run the role's real test (coherence
with the wall + purpose test) → and if it ships, make the **encoding say what it is** (color =
quality, an explicit "TRUST/STAND-DOWN" word, not a buy/sell lean that competes with the other rows).
A context gauge that can't be made coherent with the wall is a *findings note*, not a dashboard row —
and that's an honest, fine outcome to report.
