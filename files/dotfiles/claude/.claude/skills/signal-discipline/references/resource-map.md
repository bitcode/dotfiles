# Resource Map — the address book across the three layers

Everything the discipline can draw on, with absolute paths and what each is for. Three repos:

| Layer | Root | Role |
|---|---|---|
| **Theory / search space** | `$HOME\quantResearcher` | the 44-category corpus: 865+40 signals, the pipeline, eval criteria, instrument profiles, combinations |
| **Executable lab** | `$HOME\qpm` | Python: honest measurement, backtest, clustering, harvest, the manifest, the data |
| **Render target** | `$HOME\quanthropy` | C# NinjaTrader indicators + the HUD; where a survivor becomes a gauge/indicator |

> Paths and counts below were surveyed 2026-06-26. Code moves — verify a file still exists before
> asserting it as fact (memories and maps drift; the repos are the ground truth).

---

## 1. START HERE — the indexes that map each repo

- `quantResearcher\research\index.md` — master research index: phases 1-4, the 865-signal status table.
- `quantResearcher\program.md` — the research loop / methodology framing.
- `quantResearcher\Advanced-Quantitative-Taxmonomy.md` — the seed taxonomy: 25 categories + 500+ signal names.
- `quanthropy\docs\indicator-master-manifest.md` — every C# indicator: grid (name/data-tier/methods/class/status) + detailed cards (equations, blind spots). ~308KB — read in chunks or `Grep`/delegate.
- `quanthropy\docs\dashboard-hud-layout-manifest.md` — where every HUD/gauge draws (the layout rules; how to slot a new row).
- `qpm\manifest\manifest.json` + `qpm\MANIFEST.md` — qpm's system of record: which features are MEASURED / REJECTED / UNIMPLEMENTED, which combinations registered.
- The auto-memory `qpm-resume-state.md` — the live "where we are" + which signal families are already exhausted. Read it before hunting (don't re-kill a dead family).

---

## 2. THE SEARCH SPACE — the 44-category corpus (`quantResearcher\research\`)

**Signal domains (full LaTeX formulas, data reqs, theory, confidence) — `research\categories\`:**

| Cat | File (in `research\categories\`) | Domain |
|---|---|---|
| 01-12 | `01-trend-following` … `12-seasonal-*` | trend, mean-reversion, momentum, volatility, **order-flow/tape (05)**, microstructure, volume, auction, intermarket, options, sentiment, seasonal (~370 signals) |
| 13-20 | `13-*` … `20-*` | ML, information-theoretic, fractal/chaos, execution, event-driven, alt-data, exotic/novel, game-theory (~230) |
| 21-26 | `21-*` … `26-*` | network, Bayesian, wavelet, copula, TDA, cross-asset correlation (~190) |
| 27-35 | `27-crypto-defi` … `35-futures-microstructure-mbo` | asset-class + infra; **35 = futures MBO** (Globex reset, roll, cross-venue lead-lag) |

**Meta-categories (the evaluation & construction machinery):**

| Cat | File | Use it for |
|---|---|---|
| **36** | `categories\36-backtest-evaluation-criteria.md` | 64 eval criteria in 4 tiers (IC/ICIR/t-stat/PSI/SHAP … DSR/PBO/CPCV). The "how good is it" reference. |
| **37** | `categories\37-normalization-discretization-indicators.md` | 89 normalization/discretization transforms + an 8×3 indicator-target matrix. How to scale a raw signal. |
| **42** | `categories\42-strategy-construction-from-features.md` | **THE pipeline** — Stages 0-8 (cost floor → bar-clock → characterize → vet → select → combine → backtest → certify → audit). The procedural north star. |
| **43** | `categories\43-sampling-clocks-bar-types.md` | bar clocks (time/tick/volume/dollar/range), AFML taxonomy, CUSUM. Why clock choice changes everything. |
| **44** | `categories\44-instrument-profiles-per-instrument-priors.md` | per-instrument priors (NQ/ES/RTY/YM): identity → mechanics → **measured** microstructure (Hurst, VR, ACF, Kyle-λ) → strategy priors. Why a signal's direction is instrument-specific. |

**Data-requirement matrix — `research\data-requirements\`:** `l1-signals.md`, `l2-signals.md`,
`l3-signals.md` (MBO/by-order), `tick-signals.md`, `daily-signals.md`, `alternative-signals.md`.
Tells you *what data a signal needs* before you try to test it.

**Combinations — `research\combinations\`:** `two-signal\`, `multi-layer\` (incl. `futures-mbo-stack.md`),
`matrix\`, `conditional\`, `ensemble\`. 65+ worked ways to fuse signals.

**Novel — `research\novel\novel-signals.md`:** 40 cross-domain (physics/biology/network) signals.

**Selection criteria — `research\feature-selection-criteria-catalog.md`:** the 7 combine-criteria
(C1-C7) + 15+ extended (groups A-E). **Note:** these are the *reference* for the criteria; the
*executable* versions live in qpm (`qpm.manifest.criteria`, C0-C15) and the `feature-classification`
skill. Use the corpus for the *why*, qpm for the *run*.

**The implemented-feature bridge — `research\feature-master-manifest.md`:** every signal the ~65 C#
indicators actually compute, with the 6+8 tag schema. **This is the cross-walk** between the C#
indicator layer and the feature vocabulary — use it to answer "does an indicator already produce this?"

**Deep-research expansions — `research\deep-research-*.md`:** instrument profiles v2, correlation
drivers, HHI/sector-beta, POC attraction, channel strategies, dollar-bars-NT8. Focused literature pulls.

**Tier docs — `research\tiers\`:** tier3 (strategy components: entries/exits/sizing), tier4 (trading-
model architecture incl. the NT8 "one position per instrument" constraint), tier5 (portfolio/Kelly).

---

## 3. THE LAB — qpm Python (`$HOME\qpm`)

> Package import root: the `qpm` package (`qpm.research.*`, `qpm.backtest.*`, etc.). Scripts live in
> `qpm\scripts\`. Run via the project's Python env.

**Honest measurement & selection (`qpm.research.*`):**
- `qpm.research.ic` — `information_coefficient`, `partial_information_coefficient`, `icir`,
  `forward_returns`, `ic_half_life`, `decile_lift`, `kish_neff`, `newey_west_se_mean`, `autocorr`.
  **The measurement backbone — call these for every role.**
- `qpm.research.graduation` — `grade()` → G1-G18 result. **For the tradeable role only** (delegated via `feature-classification`).
- `qpm.research.cluster` — `rank_correlation_matrix`, `correlation_distance`, `cluster_features`
  (HRP + ONC silhouette + pick-one-per-cluster). **Breadth = #clusters. Use for any combine/choose.**
- `qpm.research.harvest` — `harvest_day(...)` streams a Databento MBO CSV → a per-bar parquet of 20+
  features. **Caches; don't re-harvest a cached day.**

**Backtest (`qpm.backtest.*`):**
- `qpm.backtest.engine` — `triple_barrier`, `Bracket`, `round_trip_cost_ticks`. Net-of-cost always.
- `qpm.backtest.cpcv` — `cpcv_splits`, `purge_embargo`, `deflated_sharpe`, `pbo`. Stage-6 gates.

**Manifest & criteria (`qpm.manifest.*`):**
- `qpm.manifest.schema` — `Feature`, `Combination`, `Manifest`, the enums (Axis/HalfLife/Role/…).
- `qpm.manifest.criteria` — `c0_…`..`c15_…`, `evaluate(combo, manifest)`. **Tradeable role only.**

**Feature library (compute on demand, or read from harvest cache) — `qpm.features.*`:**
- `orderflow` (OFI by age), `flow_batch` (CVD/OFI/VPIN/TFI), `book_flow` (MLOFI/Pull/Absorb/Iceberg),
  `bar_features` (Kalman-MACD/RopesHMM/POC/UO), `momentum` (TSMOM/runs), `reversion` (Bollinger-%b/RSI/
  VWAP-z/OU/Connors/%channel), `session`, `entropy`.

**Bar clocks (`qpm.bars.*`):**
- `quantbar` — `QuantBarAggregator` (QB-1/5/9 directional range bars; mechanically autocorrelated → partial IC).
- `info_bars` — `DollarBarAggregator` (~$950k/bar, near-IID → raw IC honest), `TickImbalanceBar`, `DollarImbalanceBar`.

**Instruments (`qpm.instruments`):** `Profile`, `get(symbol)` — tick size, tick value, cost floor,
measured L3 character (Hurst/VR/ACF/Kyle-λ) per clock. The executable form of Cat 44.

**Data inventory (`qpm.data.*`):** `inventory.scan_days()` (scans `D:\db-mbo`), `mbo_csv.stream_events()`.

**Canonical scripts (`qpm\scripts\`) — reusable, not one-off:**
- `complete_discipline.py` — THE canonical run: build features/day → G1-G18 → cluster → C0-C15 → manifest.
- `stage5_*.py` / `stage6_certify_*.py` — backtest + full certification battery.
- `revalidate_cvd_dollar_full.py` — re-validate the certified strategy over the full window.
- `measure_instrument_character.py`, `measure_kyle_lambda.py`, `compare_clocks.py` — characterization.
- `harvest_dollar.py` / `harvest_multiday.py` / `download_databento_mbo.py` — data pipeline.
- `adversarial_verify_*.py`, `random_entry_control.py`, `fake_reversal_test.py` — null/adversarial tests.
- The many `hunt_*.py` / `probe_*.py` are *ad-hoc* records of past hunts — read them as precedent
  (what was tried, what the harness looked like), not as canonical APIs.

**Lessons & findings (qpm root) — read as guard-rails:**
- `LESSONS.md` — L1-L9 (the hard-won rules; see judgement-method.md for the distilled list).
- `FINDINGS-oscillator-family.md`, `FINDINGS-bookshape-cluster.md`, `FINDINGS-big-move.md`,
  `FINDINGS-regime-gauge.md` — families already searched (mostly killed). Don't re-hunt blind.
- `STRATEGY-cvd-dollar.md` — the one certified strategy's full spec (sizing/deployment).

---

## 4. THE DATA (where the bytes are)

- **Raw MBO (Databento):** `D:\db-mbo\<INSTRUMENT>\*.mbo.csv` — NQ/ES/RTY/YM. NQ is continuous
  ~2026-02-17 .. 2026-06-05 (~70 trading days, multi-regime); ES/RTY/YM ~25 days each. 16-col schema
  (see the `mbo-csv-schema` memory + `quanthropy\docs\rithmic-mbo-raw-data-inventory.md`).
- **Harvested parquet (per-bar features):** `D:\qpm-harvest\<instr>\<date>_<clock>_*.parquet` —
  clocks: `qb1` and `dollar`. ~29 cols (OHLC + OFI-by-age + flow + book + bar-features).
- **Cost floors:** NQ ≈ 1.98t zero-range, ES ≈ 0.94t (per-instrument & per-clock — Cat 42 §S0.1 /
  `qpm.instruments`). A signal's per-trade move must clear this or it's a fusion/context role only.

---

## 5. THE RENDER TARGET — quanthropy C# (`$HOME\quanthropy`)

For turning a survivor into an on-chart indicator/gauge.

- **Indicators:** `QuanthropyLib\Indicators\*.cs` (~65 files). Catalogued in
  `docs\indicator-master-manifest.md` (grid + cards + the add-a-new-indicator extraction process).
- **The shared gauge widget:** `QuanthropyLib\Indicators\DashGauge.cs` — `DrawRow(rt, rowRect, lean,
  label, word, drawPanelBg)`. `lean ∈ [−1,+1]` (green-right = buy, red-left = sell), `RowHeight≈53`.
  **Every scalar dashboard gauge renders through this.** A new gauge = compute a `lean`, call `DrawRow`.
- **HUD layout:** `docs\dashboard-hud-layout-manifest.md` — the right-hand stack, the hardcoded-Y rule
  (layout lives in source, not the workspace), the "adding a new HUD" checklist. **Read before placing.**
- **Strategy catalog (executable, not indicators):** `docs\strategy-catalog.md`.
- **Gaps backlog:** `docs\indicator-gap-catalog.md` (what we lack), `docs\mbo-strategy-gap-and-wiring-plan.md`.
- **Per-family MBO enhancement plans:** `docs\*-mbo-enhancement-plan.md` (POC, cross-instrument, bands,
  grid, DM, kunai, reversion, rhythm/pulse, flowprint).
- **The 7-gauge dashboard wall** (what a new gauge must cohere with): MBOGrid, MBO-DOM, FLOW, DEPTH,
  CONSENSUS, MITA, GRID — and they collapse onto **two axes** (order-flow/book + price-momentum), both
  directional, both flip together on a fake reversal. That two-axis collapse is the gap a *context*
  gauge tries to fill — and the reason a directional-looking context gauge confuses the read.

---

## 6. Quick "where do I go for…" 

| I need… | Go to |
|---|---|
| a mechanism / formula for a gap | `quantResearcher\research\categories\*` (§2) + `novel-signals.md` |
| to know what data a signal needs | `quantResearcher\research\data-requirements\*` |
| to measure IC/ICIR/partial-IC honestly | `qpm.research.ic` |
| to vet a *tradeable* feature (hard gate) | `feature-classification` skill → `qpm.research.graduation` |
| to combine / pick one of several | `qpm.research.cluster` (breadth=#clusters) + C0-C15 (tradeable) / coherence (dashboard) |
| to backtest net-of-cost | `qpm.backtest.engine` + `qpm.backtest.cpcv` |
| per-instrument priors / cost floor | `qpm.instruments` + Cat 44 |
| has this been tried / is it built already | qpm `MANIFEST.md` + `FINDINGS-*` / `feature-master-manifest.md` / `indicator-master-manifest.md` |
| to render a survivor as a gauge | `quanthropy` `DashGauge.cs` + `dashboard-hud-layout-manifest.md` |
| fresh external literature | `deep-research` skill |
