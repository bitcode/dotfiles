# Classification Schema — the 19 tags, 6 axes, half-life, role-intent, status lifecycle

_Source: Cat 42 §I1/§I3/§A2-A3/§S1.1; feature-master-manifest "Tag Vocabulary"._

## The 19-tag schema

Populated across Stages 1-2. First 11 (Axis→Status) in Stage 1 characterization; the 8 expanded
tags across Stages 1-2 vetting. All feed Stage-3 selection (C0, C8-C15).

| # | Tag | Allowed values | Feeds | Populated |
|---|---|---|---|---|
| 1 | **Axis** | Momentum / Reversion / Order-Flow / Structure / Volatility / Time | C0 (≥3 axes) | S1 |
| 2 | **Half-life class** | MICROSTRUCTURE (≤5 bars) / TACTICAL (5-50) / STRUCTURAL (>50) / UNKNOWN | bar-clock match, holding period | S1 |
| 3 | **Role-intent** | FUSION_FEATURE / CONFIRMER / GATE / STANDALONE_CANDIDATE | which test tier | S1 |
| 4 | **Data-dependency** | L1 / L2-MBP / L3-MBO / bars-only / derived / Daily | which backtests; crowding proxy | S1 |
| 5 | **Cost-to-compute** | LOW (bars) / MEDIUM (tick) / HIGH (L2/L3 RT) | deployment feasibility | S1 |
| 6 | **IC (measured)** | numeric, per frame | "does it predict?" (G1, C2) | S2 |
| 7 | **ICIR** | numeric | "consistent?" (G2, C2) | S2 |
| 8 | **IC half-life** | bars (1/5/10/20/50) | decay profile | S2 |
| 9 | **Correlation to existing** | `\|r\|` matrix | orthogonality (G5, C1) | S2 |
| 10 | **Per-regime IC** | {Expansion, Contraction, Recovery, Crisis, Flattening} | complementarity (C3, C13) | S2 |
| 11 | **Status** | UNTESTED / VETTED-T2 / REJECTED / SELECTED / DEPLOYED | pipeline state | S1→ |
| 12 | **Execution-feasible** | FEASIBLE / MARGINAL / INFEASIBLE | C11/G14 (hard) | S1 |
| 13 | **Turnover-rate** | numeric (signals/day) | C12 | S2 |
| 14 | **Capacity-profile** | SMALL (1-5) / MEDIUM (5-20) / LARGE (20+) | C12 | S2 |
| 15 | **Crowding-risk** | LOW (L3 MBO) / MEDIUM (derived) / HIGH (published) | C14 | S2 |
| 16 | **IC-trend** | STABLE / DECLINING / DYING / IMPROVING | G17 | S2 |
| 17 | **Parameter-robustness** | ROBUST / MODERATE / FRAGILE | G15 | S1 |
| 18 | **PSI (distribution drift)** | numeric (<0.10 stable / >0.20 drift) | C15 | S2 |
| 19 | **Per-instrument IC range** | numeric (max−min across NQ/ES/YM/RTY) | C13 | S2 |

Additional characterization measures (S1.1, feed the gates): distributional shape (skew/kurt/JB,
`36 §2.9`), autocorrelation (lag-1 ACF / Ljung-Box, `36 §2.10`), activation rate (% bars ≠0,
`36 §2.3`).

## The 6 axes (Cat 42 §A2)

| Axis | Question | Typical signals |
|---|---|---|
| **Momentum / Trend** | Is price trending? which direction? | TSMOM, ADX/DI, MACD cross |
| **Mean-Reversion / Oscillator** | Is price stretched? due for a pull? | RSI, Bollinger %b, OU z-score |
| **Order-Flow / Liquidity** | Where is resting size? who is aggressing? | OFI, VPIN, CVD, MBO sweep |
| **Structure / Levels** | Where are S/R, POC, value area? | S/R bounce, POC magnet, VA fade |
| **Volatility / Regime** | Calm or violent? which regime? | GARCH, HMM, vol-target, regime gate |
| **Time / Session** | What time of day? session phase? | opening range, settlement, overnight |

**Assignment (§A3):** (1) read the formula — function of past returns → Momentum/Reversion (by
lookback sign); order-book imbalance → Order-Flow; price vs historical level → Structure; return
variance → Volatility; clock time → Time. (2) Confirm with the correlation matrix: **same cluster =
same axis** (see `axis-and-clusters.md`). (3) Re-check per regime. (4) Cross-axis feature → assign
its *dominant* (higher-IC) axis, note the secondary; do NOT count as two.

**The rule:** combine ACROSS axes, not within. Two features on the same axis mostly repeat; two on
different axes add new information. BUT axis = correlation cluster, not label — verify by matrix.

## Half-life class (Cat 42 §I2/§S1.2)

Measure IC at h ∈ {1,5,10,20,50}; half-life = h where |IC| drops to half its peak.
- **MICROSTRUCTURE** (≤5 bars): edge dies fast → QB-1; entry timing / micro-confirmer.
- **TACTICAL** (5-50): minutes → QB-5; directional signal / gate.
- **STRUCTURAL** (>50): hours+ → QB-9; regime filter / overlay.
- `|IC₁| < 0.01` → **noise** (pre-rejected). Half-life is bar-clock-relative — always state the clock.

## Role-intent (Cat 42 §I3)

| Role | Description | Test tier | Expected |
|---|---|---|---|
| **FUSION_FEATURE** | adds independent info to a combination | Tier 2 | DEFAULT (90%+); PASS = adds info |
| **CONFIRMER** | confirms/denies another signal's fire | Tier 3 | improves parent hit-rate when active |
| **GATE** | regime/vol signal that enables/disables another | Tier 2 + conditional | gated signal better when gate active |
| **STANDALONE_CANDIDATE** | gross edge > cost floor, maybe solo | Tier 4 | RARE; expect REJECT |

**The documented mistake:** treating every feature as STANDALONE_CANDIDATE. A feature that fails
Tier 4 as a standalone is NOT a failure — it's correctly classified as FUSION_FEATURE.

## Status lifecycle (tag #11)

`UNTESTED` (Stage 1) → **G1-G18 gate** → `VETTED-T2` (eligible for selection) or `REJECTED`
(failed a REQUIRED gate or pre-rejected as noise) → **C0-C15 selection** → `SELECTED` (in a 3-8
combo) → `DEPLOYED` (in a certified shipped strategy). The two transition gates are graduation
(UNTESTED→VETTED-T2) and selection (VETTED-T2→SELECTED).
