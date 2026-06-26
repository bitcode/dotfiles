---
name: signal-discipline
description: General-knowledge skill for the discipline of finding, thinking about, choosing, combining, and testing trading signals / features / indicators across the three Quanthropy layers (the quantResearcher theory corpus, the qpm Python lab, the quanthropy C# indicators). Use whenever the task is "I want to build / search for / improve a signal, feature, indicator, or gauge" — it MAPS the search space, ROUTES you to the right resource/code/data, and applies ROLE-FIRST judgement (what is this candidate FOR → measure honestly → interpret per role) WITHOUT hard-coding accept/reject thresholds. Delegates tradeable-feature graduation (G1-G18 / C0-C15 hard gates) to the feature-classification skill; for every other role it measures and interprets, you decide. Not a gauge-builder and not a fixed pipeline — it is the map + method + router for the whole craft.
allowed-tools: Bash Read Write Edit Glob Grep Skill Agent
---

# Signal Discipline — the craft of finding, judging, combining & testing signals

This is a **navigational, general-knowledge skill for a specific discipline**: turning a market idea
into a *signal / feature / indicator / gauge* — searching for it, reasoning about it, choosing
between options, combining it with others, and testing it honestly. It is **not** a pipeline with
gates and it is **not** a gauge-builder. It is three things:

1. a **MAP** of the whole search space and the three repos it lives across,
2. a **METHOD** for judging a candidate *role-first* (what is it FOR → how to measure it honestly →
   what each number MEANS for that role), deliberately **without hard-coded reject thresholds**, and
3. a **ROUTER** that points each step at the exact resource, code, or data already built.

> **Why this skill exists (the founding lesson).** The `QuantRegime` gauge (Variance Ratio) was a
> real, orthogonal, statistically-significant signal — and it was *useless on the dashboard*: it
> "pointed all over the place," never synced with the other gauges, and confused the read. The cause
> was **not** bad tuning. It was a **category error**: a *context / trend-quality* signal (green =
> "trust the wall", NOT "buy") was conceived, measured, and accepted **as if it were a tradeable
> directional feature**. The feature pipeline's pass/fail gates (IC≥0.02, ICIR≥0.3, |r|<0.7) are the
> right gates for a *tradeable feature* and the **wrong** gates for a context gauge, a confirmer, a
> regime filter, or a display — applying them universally either rejects good candidates or, worse,
> *passes* something that then fails at the job it was actually for. **The fix is role-first
> judgement, not stricter or looser numbers.** This skill encodes that.

---

## When to use this skill

Use it the moment the work is *about a signal/feature/indicator* and broader than "vet this one
column against the graduation gate":

- "I want to build a new signal / feature / indicator / gauge for X" → start here (search → role → measure → route).
- "Where do I even look for a signal that does Y?" → the MAP + corpus search (this skill).
- "Is this candidate any good / should I keep it?" → role-first judgement (this skill), delegating
  *tradeable-feature* gating to `feature-classification`.
- "How do I combine these / which one do I pick?" → the combine/choose method (this skill) + the
  C0-C15 machinery in `feature-classification` *when the goal is a tradeable combination*.
- "Turn this validated thing into an indicator/gauge on the chart" → the render router (this skill,
  reference `references/resource-map.md` → quanthropy layer).

If the task is *purely* "run G1-G18 on this feature column and tell me VETTED or REJECTED", that is
exactly what **`feature-classification`** is for — invoke it directly. This skill *calls* that skill;
it does not reimplement it.

---

## THE NON-NEGOTIABLE PRINCIPLE — role first, measure-don't-gate

**Before measuring anything, classify what the candidate is FOR.** The role determines which tests
matter and what each number *means*. The same IC of 0.01 is a kill for a standalone tradeable signal,
irrelevant for a context gauge, and fine for a confirmer. **Never reject a candidate by a threshold
borrowed from a different role.**

| Role | What it's FOR | Honest tests that MATTER | What a "low IC" / "high corr" means here |
|---|---|---|---|
| **Tradeable signal** | enters/exits a position by itself | IC/ICIR, **net-of-cost per-trade Sharpe under the real exit**, DSR/PBO, walk-forward, cross-instrument transfer | low IC → likely dead; this is the one role where the graduation gates are the right gates → **delegate to `feature-classification`** |
| **Fusion feature** | one input among several into a fused score | IC/ICIR (a floor, not a target), **orthogonality to the others** (adds breadth), marginal lift | low IC ok *if* it adds an orthogonal axis; high corr to a sibling → redundant, not additive |
| **Confirmer** | gates/strengthens another signal's entry | conditional hit-rate **when the primary fires**, lift vs primary-alone | standalone IC ≈ 0 is **expected and fine**; judge it *conditional* on the primary |
| **Gate / filter** | turns trading on/off by regime | does P&L of the gated strategy improve? false-on/false-off rates | direction-agnostic by design → directional IC is the **wrong** test |
| **Context gauge** | tells the operator *how to read* the wall (trust/stand-down) | **coherence with the existing wall** + a purpose test (e.g. continuation-rate when the wall agrees) + clock-robust sign | low magnitude is **normal**; the real test is "does a human read the wall better with it" — the regime-gauge lesson |
| **Display / HUD** | shows state, makes no claim | renders correctly, doesn't collide, doesn't mislead | no edge test at all; judge legibility + non-redundancy |

**Operational rule:** state the role in one sentence *first*. Then run **only** the tests in that
role's row, **measure honestly** (next section), **interpret per role**, and **report — do not auto-
reject**. Hard accept/reject gating is invoked **only** for `Tradeable signal` / `Tradeable
combination`, and even then via `feature-classification`, not by inlining numbers here.

---

## Honest measurement (always, regardless of role)

These are *measurement* rules, not *gates* — they make the number trustworthy; the role decides what
the trustworthy number means. (Full detail + code map: `references/judgement-method.md`.)

- **Heavy-tailed L3 features → rank (Spearman) IC**, never Pearson (kurtosis can be >20,000).
- **Per-day mean, never cross-day-pooled** (pooling inflates ~50×).
- **State the bar clock; vet on BOTH** (QB-1 *and* dollar). On range bars use **partial IC**
  (control last-bar-sign); on dollar bars (near-IID) raw IC is honest. A sign that flips across
  clocks is a range-bar artifact, not an edge.
- **Walk-forward before trusting any per-day-normalized signal** (per-day rank-norm is mildly
  anticipatory — lesson L6). **Freeze the trade sign on TRAIN** before any OOS claim (low-IC per-day
  sign-alignment is look-ahead — lesson L8).
- **Orthogonality is realized-PnL-correlation, not just per-bar feature correlation** — two signals
  can be per-bar-distinct (r=0.31) yet trade the same days (daily-PnL r=0.61) — lesson L7.
- **IC measures predictive content, not tradeable edge** — the per-trade Sharpe depends on the EXIT
  (a stop destroys a reversion signal; match exit to mechanism — lessons L4/L5). Screen by IC, judge
  by net-of-cost Sharpe under the *real* construction.
- **Cost floor is per-instrument & per-clock** (NQ ≈ 1.98t zero-range, ES ≈ 0.94t). A signal with a
  small per-trade move dies on NQ's floor regardless of IC.

The canonical implementations already exist — **call them, don't rewrite**: `qpm.research.ic`
(IC/rankIC/partial-IC/ICIR/half-life/Kish-Neff/Newey-West), `qpm.research.cluster` (HRP+ONC),
`qpm.research.graduation` (the G-gate, *for the tradeable role*), `qpm.backtest.{engine,cpcv}`
(triple-barrier + CPCV/DSR/PBO), `qpm.manifest.criteria` (C0-C15, *for the tradeable role*).

---

## The workflow (a loop, not a conveyor belt)

Use as many passes as the idea needs; skip steps that don't apply.

### A. FRAME — what are we looking for, and what role will it play?
State the gap in one sentence and the intended role (the table above). The role is the most
load-bearing decision in the whole skill — get it right and everything else follows. If unsure
between "directional signal" vs "context/regime", that ambiguity is itself the regime-gauge trap →
resolve it now, on paper, before measuring.

### B. SEARCH — find candidates in the theory corpus
The search space is **865 catalogued signals + 40 novel**, organized into 44 categories in
`quantResearcher`. Route to the right category for the gap (full index: `references/resource-map.md`
§2). Don't brainstorm from scratch — the corpus almost certainly already has the mechanism, with a
formula and a data-requirement. Note the **axis** it lives on and whether it's *mechanically distinct*
from what you already trade (axis = cluster, not label).

### C. CHECK WHAT EXISTS — don't rediscover or duplicate
Before testing, check the three "already-built" registries (`references/resource-map.md` §5):
- **qpm manifest** (`qpm/manifest/manifest.json` + `MANIFEST.md`) — is this feature already measured?
- **feature-master-manifest** (`quantResearcher/research/feature-master-manifest.md`) — is it already
  computed by an existing C# indicator?
- **indicator-master-manifest** (`quanthropy/docs/indicator-master-manifest.md`) — does a gauge for
  this mechanism already render? (Avoid building a second VR.)
- **LESSONS.md / FINDINGS-*.md** (qpm) — has this family already been hunted and killed? (Oscillator,
  book-shape, big-move, Cat-12 timeframe, lead-lag are all *exhausted* — see the resume-state memory.)

### D. ROLE-JUDGE — measure honestly, interpret per role
Run **only** the tests in the candidate's role row (table above), using the honest-measurement rules
and the canonical qpm code. For role = **tradeable**, hand off to `feature-classification` for the
G1-G18 / cluster / C0-C15 machinery. For every other role, **measure + interpret + report**; do not
apply tradeable-feature reject thresholds. Detail + worked examples: `references/judgement-method.md`.

### E. COMBINE / CHOOSE — breadth by cluster, not by label
If the goal is to combine or to pick one of several: **cluster the survivors** (`qpm.research.cluster`)
and pick one representative per cluster — effective breadth = number of clusters, NOT number of
features or labels. For a *tradeable* combination apply C0-C15 (via `feature-classification`); for a
*dashboard* set apply the **coherence** test instead (does the set read coherently to a human; does a
new member sharpen rather than contradict the wall).

### F. ROUTE THE OUTPUT — to the right home
- a **tradeable strategy** → qpm Stage-5/6 backtest + `quanthropy/docs/strategy-catalog.md`.
- an **indicator / gauge** on the chart → the quanthropy C# layer: the `DashGauge.DrawRow` shared
  widget (lean ∈ [−1,1]), the HUD layout rules in `dashboard-hud-layout-manifest.md`, and the
  add-a-new-indicator process in `indicator-master-manifest.md`. **Classify directional-vs-context
  and, if context, make the gauge's encoding say so** (color = quality, not buy/sell) — the explicit
  fix for the regime-gauge failure. Routing detail: `references/routing-cheatsheet.md`.

---

## Files

- `references/resource-map.md` — the MAP: every resource across the three repos (the 44-category
  corpus + the qpm Python modules/scripts/data + the quanthropy indicator/HUD manifests), with paths,
  one-line descriptions, and what to use each for. The router's address book.
- `references/judgement-method.md` — the METHOD: role-first judgement in depth — the role taxonomy,
  the honest-measurement rules with the exact qpm functions to call, the lessons (L1-L9 + corpus
  anti-patterns) as guard-rails, and the "measure-don't-gate" discipline with worked examples
  (including the regime-gauge post-mortem).
- `references/routing-cheatsheet.md` — the ROUTER: "I want to do X → go here / call this / read that",
  including the corpus-category lookup, the qpm code/data entry points, the data layout, and the
  C#-render path for turning a survivor into a coherent indicator/gauge.

## Composition with other skills (no duplication)

- **`feature-classification`** owns Stages 1-3 *for the tradeable role*: the 19-tag schema, the
  G1-G18 graduation gate, HRP/ONC clustering, and C0-C15 combine-criteria. This skill **calls** it for
  that role and never reimplements its gates. Think: `signal-discipline` is the *map and the judgement
  of what to test and why*; `feature-classification` is the *engine for the tradeable-feature gate*.
- **`deep-research`** is the tool when a mechanism needs fresh external literature before it's even a
  candidate (a new estimator, a paper's formula). Route there from step B when the corpus lacks it.
