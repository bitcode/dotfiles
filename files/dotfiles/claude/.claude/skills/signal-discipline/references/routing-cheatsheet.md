# Routing Cheatsheet — "I want to do X → go here"

Fast lookup. Pairs with `resource-map.md` (the full address book) and `judgement-method.md` (how to
think). When in doubt, the repos are ground truth — verify a path before relying on it.

---

## By intent

### "I have a GAP — find me a candidate mechanism"
1. Name the gap + the intended **role** (judgement-method.md Step 1).
2. Pick the corpus category by phenomenon → `quantResearcher\research\categories\` (resource-map §2).
   - direction/persistence → 01/03; snap-back → 02; vol/regime → 04/15; **order-flow/tape → 05**;
     book/microstructure → 06/34/35; volume/auction → 07/08; intermarket/lead-lag → 09/26;
     info-theoretic → 14; novel/cross-domain → `novel\novel-signals.md` + 19.
3. Cross-check it isn't already built/killed: qpm `MANIFEST.md`, `FINDINGS-*.md`, the resume-state
   memory, `feature-master-manifest.md` (already an indicator?), `indicator-master-manifest.md` (already a gauge?).
4. Note its **axis** and whether it's *mechanically distinct* from what you trade (axis = cluster).

### "Is this candidate any good?"
→ judgement-method.md. Role first → measure honestly (`qpm.research.ic`) → interpret per role.
- role = tradeable → invoke **`feature-classification`** (it runs G1-G18 / cluster / C0-C15).
- role ≠ tradeable → measure + interpret + report; no hard reject.

### "Measure IC / ICIR / partial-IC / half-life"
→ `qpm.research.ic`: `information_coefficient` (set `method="spearman"` for L3),
`partial_information_coefficient` (range bars), `icir`, `ic_half_life`, `decile_lift`.
Per-day mean, both clocks, state the clock.

### "I have several survivors — combine or pick one"
→ `qpm.research.cluster.cluster_features` (HRP + ONC). **Breadth = #clusters**, pick one rep per cluster.
- tradeable combination → C0-C15 via `feature-classification`. Judge by Δ(net Sharpe), not ΔIC (L1).
- dashboard set → **coherence test** instead (does the set read coherently; does the new member
  sharpen rather than contradict the wall). Confirm orthogonality by **daily-PnL corr** (L7), not per-bar.

### "Backtest it net-of-cost"
→ `qpm.backtest.engine` (`triple_barrier`, `Bracket`, cost model) + `qpm.backtest.cpcv` (`cpcv_splits`,
`deflated_sharpe`, `pbo`). **Match the exit to the mechanism** (L4): reversion → timeout/no-stop;
momentum → stop. Precedent: `stage5_*.py`, `stage6_certify_cvd_dollar.py`.

### "What data does this need / is it on disk?"
→ `quantResearcher\research\data-requirements\{l1,l2,l3,tick,daily,alternative}-signals.md` for the
requirement; `qpm.data.inventory.scan_days()` + `D:\db-mbo\<INSTR>\` (raw) and
`D:\qpm-harvest\<instr>\*_{qb1,dollar}_*.parquet` (harvested) for what's on disk. Harvest a missing day
with `qpm.research.harvest.harvest_day` / `harvest_dollar.py` (caches).

### "Per-instrument priors / cost floor / will it transfer?"
→ `qpm.instruments.get(sym)` (executable) + Cat 44 (`44-instrument-profiles-…md`). Remember L3:
direction often does NOT transfer (NQ-specific). Cost floor: NQ ≈ 1.98t, ES ≈ 0.94t.

### "Has this family already been hunted?"
→ qpm `FINDINGS-*.md` + resume-state memory. **Already exhausted (mostly killed):** oscillator/
reversion family, book-shape cluster, big-move, Cat-12 timeframe, NQ-ES lead-lag, structure/vol on
dollar, trend/momentum on dollar. Don't re-kill — read the findings, then go somewhere genuinely new.

---

## Turning a survivor into an INDICATOR / GAUGE (the C# render path)

Only after the candidate has been role-judged and survives. Target: `$HOME\quanthropy`.

1. **Classify directional vs context — and encode it honestly.** This is the regime-gauge fix.
   - *directional* → a normal `lean ∈ [−1,+1]` row; green = buy, red = sell. It must **sync** with the
     wall (same sign convention, same axis meaning).
   - *context / quality / regime* → its color must mean **quality, not direction** (e.g. green = "trust
     the wall", red = "stand down"), with a state WORD that says so. Never let a context gauge wear a
     buy/sell costume — that's what made VR "point all over the place."
2. **Use the shared widget.** `QuanthropyLib\Indicators\DashGauge.cs` → `DrawRow(rt, rowRect, lean,
   label, word, drawPanelBg)`. Compute your scalar → normalize to `lean` → call `DrawRow`. Don't build
   a bespoke widget (the uniformity redesign collapsed all scalar gauges to this one).
3. **Place it by the layout rules.** `docs\dashboard-hud-layout-manifest.md`: right-hand stack
   (Family A), **hardcode the Y literal** in `OnRender` (layout lives in source, NOT the workspace),
   anchor X off the primary price panel, follow the "adding a new HUD" checklist, and **update the
   manifest in the same change**.
4. **Coherence gate (a human test, not a number).** Before shipping: does the new row, read alongside
   the existing 7-gauge wall, make the read *clearer*? If it contradicts or muddies, it's a findings
   note, not a row. (The wall collapses to two directional axes — order-flow/book + price-momentum —
   both of which flip on a fake reversal; a context gauge earns its slot only by *disambiguating* that,
   not adding a third thing that flips too.)
5. **Catalog it.** Add the grid row + detailed card via the process in
   `docs\indicator-master-manifest.md` (one indicator per pass; record equation, class, named methods,
   data tier, validation status, blind spot).

---

## Turning a survivor into a STRATEGY (the trade path)
→ qpm Stage-5/6 (`stage5_*.py` / `stage6_certify_*.py`), then `quanthropy\docs\strategy-catalog.md`
(+ the NT8 deployment path: `DollarBarsBarsType.cs` / `StratNqCvdDollar.cs` as the worked precedent).
Sizing/risk: Cat 33 + tier5 + the `risk_*` scripts + the `qpm-risk-management-cvd-dollar` memory.

---

## When the corpus doesn't have it
→ invoke the **`deep-research`** skill for fresh external literature (a new estimator, a paper's
formula), then bring the mechanism back into step B (search) as a candidate.

---

## One-screen flow

```
FRAME (gap + ROLE)                         ← judgement-method §Step 1
  → SEARCH corpus (Cat 1-44)               ← resource-map §2
    → CHECK already-built/killed           ← MANIFEST / FINDINGS / feature-master / indicator-master
      → ROLE-JUDGE (measure honestly,      ← judgement-method §Step 2-3 ; qpm.research.ic
         interpret per role)
        → if tradeable: feature-classification (G1-G18 / C0-C15)   ← delegate the hard gate
           else: measure + interpret + report (no hard reject)
          → COMBINE/CHOOSE (cluster; breadth=#clusters)            ← qpm.research.cluster
            → ROUTE OUTPUT:
                strategy → qpm Stage-5/6 → strategy-catalog
                gauge    → DashGauge.DrawRow → HUD manifest → coherence gate → indicator-master
```
