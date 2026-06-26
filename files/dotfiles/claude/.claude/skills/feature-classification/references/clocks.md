# Sampling Clocks — properties + the clock↔feature mapping (condensed)

_Full treatment: quantResearcher Cat 43 — incl. §43.11 (clock-induced SEMANTIC shifts),
§43.12 (clock-induced CORRELATION structure), §43.16 (clock-selection framework + 7-axis×10-clock
compatibility matrix). The clock is the 2nd search axis (feature × CLOCK × horizon × regime). The
SAME feature has DIFFERENT edge on different clocks — verified, see below. Two findings below
(semantic shift, clock-conditional clusters) change the Stage-1 and Stage-3 workflow directly._

## Clocks available in QPM (computed in qpm.research.harvest)
- **dollar** — close every $N notional. NEAR-IID returns (NQ lag-1 ACF ≈ +0.002). The HONEST
  measurement clock: raw rank-IC is valid, no partialling needed.
- **QB-1 / QB-5 / QB-9** — QuantBars directional range bars (rangeMax=V·tick, maxRange=(2V+1)·tick,
  V∈{1,5,9}). MECHANICALLY autocorrelated (NQ QB-1 lag-1 ACF ≈ +0.16). Raw IC INFLATED → must use
  partial-IC / verify. Pre-whiten micro-noise → suit trend/momentum.
- (time / tick / volume / imbalance — catalogued in Cat 43, not yet harvested in QPM.)

## The autocorrelation rule (load-bearing)
- IID clocks (dollar) → raw rank-IC honest.
- Range clocks (QB) → raw IC inflated; a direction-tracker "predicts" by re-deriving bar
  autocorrelation. Control via **partial-IC** (residualize feature+fwd-return on last-bar-sign),
  and verify (deep control vs lag-2; shuffled-feature null).

## h=1 range-bar POISON
On range bars, forward return at h=1 is one clamped bar (≈±range). Features show absurd partial-IC
(0.3-0.42, ICIR 17) at QB h=1 that COLLAPSE by h5/h10 — pure artifact. **Exclude h=1 on range
bars; require non-collapsing decay (|IC₅|/|IC₁| not tiny). Trust h≥5.**

## Verification battery for ANY range-bar/QB feature (must pass ALL)
1. partial-IC (vs last-bar-sign) ≥ 0.02 at h≥5 (not h=1).
2. deep control (vs lag-1 AND lag-2 sign): IC barely moves (else it was residual autocorrelation).
3. shuffled-feature null: shuffle feature within day → shuffled-IC ≈ 0 (< real/3); else it's clock
   structure, not the feature.
(`scripts/adversarial_verify_qb1.py` implements this.)

## The clock↔feature-type mapping (use the right clock per feature-type)
| Feature type | Best clock | Why |
|---|---|---|
| Momentum / Trend / persistence | **range (QB-1/5)** | range pre-whitens noise; matches continuation |
| Mean-reversion / oscillator | **dollar / volume** | needs unbiased mean; IID clock |
| Order-flow / signed flow | **dollar / volume / imbalance** | activity-normalized |
| Realized vol (GARCH/HAR), fixed-Δt | **time** | variance needs equal Δt |
| Time-of-day / seasonal / session | **time** | the signal IS the wall-clock |
| Structure / levels (S/R, POC) | **dollar / range** | price-driven sampling aligns to levels |
| Microstructure / queue / lead-lag | **tick / sub-second** | edge decays before coarse bars close |

## Semantic shift — the same formula is a DIFFERENT feature on a different clock (Cat 43 §43.11)
The clock doesn't just change a feature's resolution — it changes **what the feature measures**, so
a feature's **AXIS can change with the clock**. Consequences for Stage 1 (characterize):
- **Assign axis PER-CLOCK, not once.** Examples (verified): CVD on dollar = per-dollar toxicity
  (Order-Flow); on QB-1 = inverse Kyle-λ / per-tick depth — a different signal. OU z-score on
  dollar = vol-adjusted overextension (Reversion); on QB-1 the ATR denominator goes ~constant so it
  collapses to distance-from-POC (Structure). OBOS/MACD/Ropes on QB-1 all reduce to *directional
  persistence* (one momentum quantity) but measure different things on dollar.
- **Don't carry a dollar-clock axis tag onto the range clock.** Re-derive it. The §43.6 "best clock
  per type" mapping assumes the feature still MEANS what its name says — semantic shift can break that.
- **Class C — INAPPLICABLE on a clock:** a feature the clock DESTROYS (e.g. ATR/realized-vol on
  range bars → constant; fixed-Δt features on event clocks) must be tagged "INAPPLICABLE on clock C"
  and excluded — using it yields a trivial/constant quantity that can fake edge via bar-construction
  autocorrelation (§43.5). (Full compatibility matrix: Cat 43 §43.16.)

## Clusters are CLOCK-CONDITIONAL — cluster ON the clock you'll trade (Cat 43 §43.12)
The skill's core rule is "axis = correlation CLUSTER, not label." That cluster structure is itself
**clock-dependent**: semantic convergence/divergence (§43.11) reshapes the correlation matrix.
- Features ORTHOGONAL on one clock can be COLLINEAR on another (and vice versa) — *predictably*.
  VERIFIED: ropes/macd/obos are mutually r 0.6–0.74 on QB-1 (they converge to one directional-
  persistence bet) but ~0 correlated on dollar (different quantities). cvd ⊥ trend on BOTH clocks
  (flow ≠ price-trend is clock-invariant).
- **RULE: build the correlation-distance matrix and pick representatives ON THE CLOCK YOU INTEND TO
  TRADE.** A dollar-clock cluster map does NOT transfer to QB-1. Effective-N (breadth) is clock-
  specific. Re-cluster per clock; never reuse another clock's selection.
- Prediction shortcut (§43.12): if a clock makes two features measure the same thing, ρ→high there.
  Flow vs price-trend stays ⊥ everywhere; momentum-family features converge on range clocks.

## VERIFIED on NQ (25 days) — edge IS clock-dependent
| Feature (type) | dollar (raw IC) | QB-1 (partial-IC h5) |
|---|---|---|
| cvd (flow) | **−0.05 works** | −0.015 weak |
| ou-zscore (reversion) | **+0.025 works** | +0.006 weak |
| ropes-hmm (trend) | +0.013 dead | **+0.107 works (verified)** |
| kalmanmacd (momentum) | −0.006 dead | **+0.052 works (verified)** |
| obos (osc) | +0.008 dead | **+0.063 works (verified)** |
| ofi-age-young (<1s OFI) | +0.002 dead (raw) | **−0.0214 contrarian, verified h5+h10** |
| bf_absorb (absorption) | — | **+0.063 verified h5-ONLY (fast-decay)** |

_NB: ofi-age-young was REJECTED on RAW dollar IC — but raw IC is the WRONG metric on range bars.
Its real QB-1 edge is PARTIAL-IC. Never trust a raw-IC rejection to rule a feature out of the
range clock. Also: the 3 highest-ICIR QB-1 flow features (fb_ofi 6.24, kalmanmacd, fb_tfi) CLUSTER
WITH ropes-hmm (r 0.5-0.83) = the SAME bet — cluster the survivors (HRP/ONC) before picking; ICIR
ranking alone walks straight into the axis-label trap._

## Operational rules
- STATE the clock on every number. NEVER pool across clocks (each clock = separate strategy).
- Measure a feature on the clock that matches its TYPE; verify honesty per the battery above.
- On QB-1, ropes/macd/obos are mutually r 0.6-0.74 (ONE trend cluster) but cvd is ~0.00 to them →
  {cvd flow} + {trend rep} is a 2-orthogonal-cluster QB-1 combination.
