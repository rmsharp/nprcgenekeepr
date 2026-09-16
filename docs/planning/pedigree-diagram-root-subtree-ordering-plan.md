# Pedigree Diagram: Root-Subtree Ordering Pass (Shape A) — Design

**Date:** 2026-09-16 (Session 688) · **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
**Trigger:** `BACKLOG.md` Up Next item 1 — "Design the root-subtree ordering pass (Shape A)",
owner-ratified S686 (2026-09-11) via `AskUserQuestion` from the sibling-order appetite
measurement ([`pedigree-diagram-sibling-order-appetite-evidence.md`](pedigree-diagram-sibling-order-appetite-evidence.md));
standing pedigree-fidelity directive (`BACKLOG.md` header note, S643).
**Scope:** Design only. No production `R/`/`tests/` change ships this session. Every number
below was measured this session through the **unmodified** engine — either as a pure
ped-row permutation (Learning 739's permutation-spike pattern) or by calling this package's
own unmodified internal functions from scratch scripts (`scratchpad/s688_*.R`, untracked —
take before cleaning `scratchpad/`). Per the S675 mandate this design **adds no QP
objective term and tunes no weight**.
**Decisions below are recommendations, not yet owner-ratified** (S676 precedent): each
implementing session's PRE-RED `AskUserQuestion` gate is where ratification happens, with
this document's measurements as the decision input. Two decisions (calibration source,
seed) carry a measured "upgrade" alternative the owner may prefer — §Alternatives.

---

## Context

### Problem statement

On the real 375-individual fixture, 99.8% of the 570,645 px of curved duplicate-connector
ink is **cross-root-subtree**: 125 of the 127 connectors join a duplicate occurrence in one
founder's subtree to the real individual in another founder's subtree (S686 §3; re-counted
this session: 127 connectors, 125 cross-root, 2 intra-root). Which founder subtrees sit
next to each other is decided by nothing but **ped row order** — an arbitrary input
property — so 644 of 1,485 pulled-root pairs are inverted and the connectors form the
"dome" the owner flagged. S686 measured that a real optimizer over the root order recovers a
third of that ink; the naive barycenter analogue (kinship2's `autohint` mechanism) measured
*worse* every iteration (dense minimum-linear-arrangement, not kinship2's sparse case).

### Where root order enters the engine (verified by reading the code, not the docs)

| Step | Code | What it does with order |
|---|---|---|
| founders in ped row order | `R/makePedigreeDiagramData.R:961` `founderIds <- Filter(function(id) !hasParentEdge(id), realIds)` | `realIds` is `ped$id` in row order |
| roots | `:983` `rootIds <- union(setdiff(founderIds, b1Ids), orphanChildIds)` | inherits row order |
| super-root's children | `:985` `.buildForestChildrenOf(rootIds, childrenOf, superRootId = "__super_root__")` | `rootIds` **is** the super-root's child list, verbatim (`R/positionTreeApportion.R:273-275`) |
| BJL tree discovery | `R/positionTreeApportion.R:53-64` `.discoverApportionTree()` | siblings numbered in `childrenOf()` order → left-to-right placement |
| Tier-1 positions | `:987` `tier1X <- .positionTreeApportion("__super_root__", forestChildrenOf)` | every downstream stage (S666 shift, Tier 2/3, Decision-1 seeding, `.solveJointQP()`) consumes `tier1X` |

Nothing else reads root order. **So the whole lever is the order of one character vector,
`rootIds`, at one line.** Re-ordering it in place is exactly equivalent to S686's
founder-row permutation (S686's own §1 finding, re-verified below), without permuting
anything.

### A correction to the S686 handoff's "renumbering" gotcha

S686 warned that "any row permutation renumbers `__union_N` ids (first-appearance order)",
so test pins and screenshots would churn. **Measured this session: not for a root-only
permutation.** Applying S686's own converged permutation (`scratchpad/s686_ped_best.csv`,
50 rows moved — every one a founder with no recorded parent) and rebuilding the forest:

```
matingUnits identical (id,sire,dam,anchor,nonAnchor,gen): TRUE
duplicates identical:                                     TRUE
childEdges identical:                                     TRUE
component partition identical (as sets, same order):      TRUE
```

Mechanism: `__union_N` is numbered by first appearance among rows **with both parents**
(`:426-447`, `uniqueKeys <- unique(pairKey[hasBoth])`), duplicates are numbered per parent
in unit order (`:556-582`), child edges follow child rows (`:594-599`), and components are
keyed by each component's *smallest* member row (`:637-662`) — a founder row never enters
the first three, and moving rows only among a component's own roots cannot change its
minimum. The one root kind that *does* carry a both-parents row is an orphan child (issue
#154, both parents dangling; `:975-983`) — 0 on Real 375 — and the in-engine placement
below never permutes ped rows at all, so even that case cannot renumber.

### Constraints

- **Determinism across the CI matrix.** `R-CMD-check.yaml` runs Ubuntu/macOS/Windows and
  the pedigree suites pin exact numeric positions (6,600+ lines, §Inventory). An ordering
  decision that differs by platform is a *discrete* change — a different layout, not a
  1e-12 jitter — and would fail every Real-375 pin on one OS. Anything eigen/LAPACK-based
  is a hazard here; anything in plain IEEE-double arithmetic is not.
- **The five kinship2-bit-exact packing fixtures** (Track B full/shrunk, D1–D3) must stay
  byte-identical (the S675/S676/S683/S685 invariant).
- **Cost.** Positioning is 1.74 s of the 1.86 s full rectilinear layout on Real 375, and
  `.solveJointQP()` is **94%** of positioning (1.38 s; measured via `trace()`); Tier-1 BJL
  is 0.01 s. `quadprog` is a dense active-set solver, so the QP scales roughly cubically —
  at issue #138's 1,500-node direct cap the QP already dominates by a wide margin. **A
  design that runs the QP twice doubles the one cost that does not scale.**
- **No new dependency; no new node kind or id prefix; no objective/weight change** (S675
  mandate, unchanged since).
- **Signatures and contracts unchanged:** `.positionMatingUnitForest(ped, forest) ->
  data.frame(id, x, gen)`; `makePedigreeMatingLayout()`'s public contract.

### Current state → fate under this design

| Stage (`R/makePedigreeDiagramData.R`) | Fate |
|---|---|
| `.buildMatingUnitForest()` (:399–603) | **Unchanged** — ids, duplicates, edges identical by construction |
| `.forestComponents()` / `.packComponents()` / per-component recursion (:634–738, :873–882) | **Unchanged** — family order stays kinship2's ped order (S667) |
| `rootIds` assembly (:961–983) | **Unchanged** as the *input* to the new pass |
| **NEW: `.orderRootSubtrees()`** — between :983 and :985 | reorders `rootIds`; identity when nothing to gain |
| Tier-1 BJL (:985–988), `sweepMinSepBackstop()`, S666 shift, Tier 2, Tier 3, Decision-1 seeding (:990–1312) | **Unchanged code**; consume the reordered `rootIds` |
| `.solveJointQP()` (:1416–1588) | **Unchanged** — floors, terms, weights |
| `.addRectilinearWaypoints()` / `.resolveEdgeNodeCollisions()` | **Unchanged** |

---

## Evidence — measurements this session (Real 375 unless stated)

Method: `scratchpad/s688_timing.R`, `s688_seed.R`, `s688_m5.R`, `s688_m6.R`,
`s688_realize_rcm.R`, `s688_census_{rcm,spectral}.R` (a copy of S686's byte-faithful
census harness pointed at this session's permuted ped). Baseline reproduced S686's
committed numbers exactly (span 570,645; cXs 1,740; cXc 931; sXs 192; width 13,740)
before any candidate was trusted. "TRUE" = measured on the full unmodified layout after
realizing the candidate order as a founder-row permutation.

### 1. Cost anatomy

| Stage | Real 375 |
|---|---:|
| `.buildMatingUnitForest()` | 0.01 s |
| `.positionMatingUnitForest()` (Tier 1 + seeding + QP) | 1.74 s |
| — of which `.solveJointQP()` | **1.38 s (94%)** |
| — of which Tier-1 BJL (`.positionTreeApportion()` on the whole forest) | **0.01 s** |
| full `makePedigreeMatingLayout(edgeStyle = "rectilinear")` | 1.86 s |
| ordering optimizer, one seed, k = 50 roots, m = 125 connectors | 0.23–0.30 s (≈10 local-search sweeps) |

### 2. The design matrix: calibration source × seed, ONE round

| Calibration (block widths / connector endpoints from…) | Seed | connector ink (px) | Δ | chord×straight | chord×chord | added cost |
|---|---|---:|---:|---:|---:|---:|
| *baseline (current order)* | — | 570,645 | — | 1,740 | 931 | — |
| full pass-1 layout (QP-solved positions) | current order | 393,512 | −31.0% | 1,282 | 616 | +1.7 s (a second QP) |
| full pass-1 layout | spectral (Fiedler) | 379,452 | −33.5% | 1,255 | 595 | +1.7 s |
| **Tier-1 BJL only (no QP)** | current order | 413,852 | −27.5% | 1,388 | 594 | +0.3 s |
| **Tier-1 BJL only** | **reverse Cuthill–McKee** | **411,729** | **−27.8%** | **1,128** | **545** | **+0.3 s** |
| Tier-1 BJL only | spectral (Fiedler) | 394,006 | −31.0% | 1,272 | 580 | +0.3 s |
| *S686 reference: 3 rounds, QP-calibrated, spectral+current* | | 382,911 | −33% | 1,316 | 604 | +3× QP |

Two readings. (a) **Calibrating from Tier-1 alone costs ~3 points of ink against calibrating
from the QP-solved layout, and saves a whole QP solve** — the Tier-1 geometry is a good
enough proxy of the final block widths for the *ordering* decision. (b) **The seed is worth
~3 points too**: spectral beats RCM/current at either calibration — but RCM has the *best
crossing counts* of every variant (−35% chord×straight, −41% chord×chord vs baseline).

### 3. Iteration (recalibrate on the realized layout, optimize again)

| Rounds | QP-calibrated (S686's loop) | Tier-1-calibrated, RCM | Tier-1-calibrated, spectral |
|---|---:|---:|---:|
| 1 | 393,512 (−31.0%) | 413,852 (−27.5%) | 394,006 (−31.0%) |
| 2 | 382,911 (−33%) | **623,818 (+9.3%)** | **554,651 (−2.8%)** |
| 3 | 390,562 (stop) | 600,393 | 564,127 |
| 4 | — | 547,100 | 581,790 |

At the QP level one round captures 94% of the converged gain. **At the Tier-1 level
iteration diverges** — the second round is worse than the *baseline* — because Tier-1
block geometry itself changes with order (BJL packs per-row contours, so subtree widths
interleave), and the proxy then chases a moving target. → **one round, no recalibration
loop** (Decision 4).

### 4. Pinned-fixture safety (checked, not assumed)

| Fixture | roots / components / cross-root connectors | Result under the design (any seed) |
|---|---|---|
| Track B full | 3 / 3 / 0 | identity permutation |
| Track B shrunk | 2 / 2 / 0 | identity |
| D1 | 2 / 2 / 0 | identity |
| D2 | 3 / 3 / 0 | identity |
| D3 | 2 / 2 / 0 | identity |
| Track C | 3 / 1 / 3 | order changes P1,X,W → X,P1,W (Tier-1-level span 600 → 360) — **but the full layout's positions are identical** (`all.equal` at 1.5e-8 for every node; TRUE span 510 both ways). The QP reaches the same solution either way. |

So all six are **output-identical**; five of them by construction (nothing to order), Track C
by the QP being indifferent. Track C's *bitwise* identity is not guaranteed (a different
`rootIds` order changes Tier-1's insertion order → `pos` row order → QP variable order →
possible ≤1e-15 jitter); its pins use `expect_equal` and hold — see Open Question 5 for
the case where a digest-style bitwise check ever needs it.

### 5. Determinism

- RCM + local search: repeat runs identical; **the whole pass is plain IEEE-double
  arithmetic** — Tier-1 BJL uses only `+ − × ÷` (`R/positionTreeApportion.R`; no LAPACK, no
  BLAS, no `quadprog`), so block widths, offsets and every proxy comparison are bitwise
  reproducible across R builds and OSes. This is a property the QP-calibrated variants do
  not have (different compilers/FMA can move a `solve.QP()` result at the 1e-12 level, which
  is harmless for a *position* pin but can flip a near-tie *ordering* decision).
- Spectral: Real 375's big component (50 roots) has a **connected** connector graph, so its
  Fiedler vector is well-defined here; but 2 roots elsewhere have 0 connectors, and any
  pedigree whose connector graph is disconnected within a component (or has an
  automorphism — two founders wired identically) has a degenerate/ambiguous Fiedler vector
  whose `eigen()` output is LAPACK-dependent. Guards exist (per-connected-subgraph, canonical
  sign, spectral-gap check, rounded coordinates with current-position tie-break) but each is
  a place for a platform-dependent flip to hide. Rejected for this design; recorded as the
  measured upgrade (§Alternatives 2).

### 6. Structural facts used by the design

Real 375 after isolate filtering: 375 individuals, 237 units, 170 duplicates, 5 weakly-
connected components with 2 / 1 / 1 / 3 / **50** roots; 55 roots carry ≥1 connector; the
50-root component's connector graph is one connected component. Components with ≤ 2 roots
are skipped by construction (nothing to order).

### 7. The census (the project's acceptance gate) on the realized orders

S686's byte-faithful harness copy, pointed at each candidate order realized as a founder-row
permutation (`scratchpad/s688_census_{rcm,spectral}.R`, findings CSVs alongside). Track B
full/shrunk, Track C, D1–D3 rows: all-zero, identical to the committed baseline, in both runs.

| Real 375 | jogs | a | **b** | c1Pre | c1Post | c2 | **cCurved** | d | e | f |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| baseline (S685 engine, current order) | 95 | 0 | 12 | 10 | 0 | 0 | 1,996 | 0 | 0 | 0 |
| S686 reference (3 rounds, QP-calibrated, spectral+current) | 102 | 0 | 12 | 6 | 0 | 0 | 1,278 | 0 | 0 | 0 |
| **Tier-1 calibration, RCM seed (recommended)** | **93** | 0 | **8** | 6 | 0 | 0 | **1,667** (−16%) | **1** | 0 | 0 |
| Tier-1 calibration, spectral seed | 114 | 0 | **17** | 8 | 0 | 0 | **1,343** (−33%) | 0 | 0 | 0 |

Three things this table says that the ink numbers alone did not:

- **Class (b) is order-sensitive**, as Learning 727 predicted (an order-bound residual), and
  it moves in *opposite* directions under the two seeds: RCM 12 → 8 (of the 8, two are
  ≤ 1e-6 dust rows — `__union_75`, `__union_132` — so 6 substantive vs the baseline's 7:
  `__union_128`/`__union_179` cleared, `__union_191` appeared); spectral 12 → 17. S686's
  permutation happening to leave b at 12 was a coincidence, not an invariant. **a, c1Post,
  c2, e and f are the true invariants** (QP floors, the repair pass, the S685 band, S678's
  duplication policy, family packing) — 0 in every run.
- **The seeds diverge most on the census's own dome metric.** cCurved (curved chords passing
  through symbols) is the closest census proxy for the clutter the owner flagged: RCM
  removes 16% of it, spectral 33% (S686's converged loop: 36%). Ink (−27.8% vs −31.0%)
  understates this gap.
- **RCM opens one class-(d) case** — `__dup_SLN0TF_2` lands exactly `minSep` (120 px) from
  its own real occurrence `SLN0TF` at `__union_90`, with nothing between — the same class
  the S683 wDup exclusion cleared (1 → 0) and the provisional-order design's Open Question 1
  declined to collapse (kinship2's `alignped3` merges such a pair). One pair; disclosed.
  Spectral: d 0, but jogs 95 → 114 (+19 repair corridors) and b +5.

Neither seed dominates. RCM improves four classes (jogs, b, c1Pre, cCurved) and worsens one
by a single pair; spectral improves cCurved twice as much and worsens b and jogs. The
recommendation below keeps RCM for its determinism and its census profile, and hands the
choice to the PRE-RED gate with this table as the input.

---

## Decision

### Decision 1 — Placement: reorder `rootIds` in place, inside `.positionMatingUnitForest()`

Insert one call between `:983` and `:985`:

```r
rootIds <- union(setdiff(founderIds, b1Ids), orphanChildIds)      # :983, unchanged
rootIds <- .orderRootSubtrees(rootIds, childrenOf, matingUnits,   # NEW
                              duplicates, minSep)
forestChildrenOf <- .buildForestChildrenOf(rootIds, childrenOf,   # :985, unchanged
                                            superRootId = "__super_root__")
```

`.orderRootSubtrees()` is a new **internal, pure** function (`@noRd`) that returns a
permutation of its `rootIds` argument. Because it runs inside the single-component branch,
it is automatically per-component (the S667 recursion at `:873-882` hands each family in
alone). It never sees or touches `ped`, so `.buildMatingUnitForest()`'s ids, the component
partition, and `makePedigreeMatingLayout()`'s `nodes` row order (built from `realIds` in
ped order, `:1859`) are unchanged by construction — the §Context correction becomes a
guarantee rather than a measurement.

**Interface contract**

| | |
|---|---|
| Input | `rootIds` (character, ≥1, the incoming order); `childrenOf` (the closure at `:907`); `matingUnits`, `duplicates` (this component's forest tables); `minSep` (the engine's raw-unit spacing, `1`) |
| Output | character vector: a permutation of `rootIds` — same elements, same length; **`identical(out, rootIds)` whenever `length(rootIds) <= 2`, or no connector joins two different roots, or no candidate order strictly beats the incoming order's proxy** |
| Error | `stop()` on a non-character/NA/empty `rootIds`, matching `.buildForestChildrenOf()`'s own guard; never errors on structure (a root with no members, a duplicate whose unit has no anchor, etc. — such connectors are simply not counted) |
| Determinism | a pure function of its arguments; no RNG, no `eigen()`, no `solve.QP()`; bitwise reproducible across platforms |
| Cost | one Tier-1 BJL pass (0.01 s) + local search bounded by `maxSweeps` (Decision 3) |

### Decision 2 — Calibration: Tier-1 BJL geometry, not the QP-solved layout

Inside the pass, run `.positionTreeApportion("__super_root__", .buildForestChildrenOf(rootIds,
childrenOf))` once with the **incoming** order (exactly the call `:985-988` will make again
with the new order). From its `tier1X` (raw units):

- **Block** of root `r` = the rendered cluster S686 defined: `r`'s subtree members
  (`childrenOf()` closure), plus every mating unit anchored by a member, plus every
  duplicate minted at such a unit. Block **left** / **width** = range of `tier1X` over the
  block's *real* members (units/duplicates have no Tier-1 x; they lie inside their anchor's
  span).
- **Connector** endpoints: real occurrence → its own `tier1X`; duplicate occurrence → its
  unit's **anchor's** `tier1X` (a proxy; 170/170 duplicates on Real 375 have one). Each
  endpoint is stored as an **offset from its block's left edge**, so it rides with the block
  under reordering. A connector whose two roots are the same, or whose endpoint has no
  Tier-1 x (a B1 free-pass real), is dropped from the objective.
- **Proxy layout** of an order `o`: blocks laid left-to-right with gap `minSep`
  (`left[o_1] = 0; left[o_{i+1}] = left[o_i] + width[o_i] + minSep`) — mirroring
  `.packComponents()`'s own per-row `minSep` gap. **Objective** =
  `Σ_connectors |(left[rootDup] + offDup) − (left[rootReal] + offReal)|` (connector ink).

Measured: −27.8% ink (RCM) with this calibration vs −31.0% from a full QP-solved pass-1 —
3 points for a saved 1.4 s that scales cubically, plus bitwise determinism (§Evidence 5).
The proxy is coarse either way (S686: 2.7× vs true; Tier-1 subtrees interleave per row so
rigid blocks over-estimate width) — it is an *ordering* heuristic, disclosed as such.

### Decision 3 — Seed and search: reverse Cuthill–McKee, first-improvement local search, accept only on strict proxy improvement

1. **Seed.** Build the root connector graph `W` (one undirected edge per cross-root
   connector, multiplicity kept). Order it by **reverse Cuthill–McKee**: start at the
   minimum-degree root (ties → current position), breadth-first, neighbours by ascending
   degree (ties → current position); a root with degree 0 starts its own trivial BFS (so
   unconnected roots trail, in current relative order); reverse the visit order. Integer
   arithmetic only.
2. **Local search** from the seed, first-improvement: one sweep = every pairwise swap
   `(i, j)` then every single-block move `(i → j)`, accepting a candidate iff
   `proxy(candidate) < proxy(incumbent) − 1e-9`; repeat sweeps until none improves or
   `maxSweeps = 20` (Real 375 needs ~10; the algorithm is anytime — the incumbent is valid
   at any cutoff).
3. **Acceptance.** Return the searched order only if `proxy(result) < proxy(rootIds) − 1e-9`;
   otherwise return `rootIds` unchanged. This is the prefer-current-order tie-break the S686
   item asked for, and it is what makes the five connector-free fixtures identity by
   construction (their proxy is 0 with nothing to improve — the early-exit for "no cross-root
   connector" returns before any search).

Why RCM over the current order alone: it measured slightly better ink (−27.8% vs −27.5%)
and clearly better crossings (1,128/545 vs 1,388/594), and a bandwidth-reduction ordering
is the standard deterministic counterpart of the Fiedler ordering for exactly this
(minimum-linear-arrangement-like) problem. Why RCM over spectral (the owner's call at the
gate — §Evidence 7): RCM is deterministic by construction and its census profile is jogs
95 → 93, b 12 → 8, c1Pre 10 → 6, cCurved −16%, d 0 → 1; spectral buys cCurved −33% (the
dome metric) at b 12 → 17 and jogs +19, plus the `eigen()` determinism guards
(§Evidence 5, §Alternatives 2).

### Decision 4 — One round; no recalibration loop

The pass runs once per component per layout. §Evidence 3 measured that recalibrating on
the reordered Tier-1 geometry diverges (+9.3% *worse than baseline* at round 2). The QP-
level loop S686 used converges but needs a QP solve per round (Alternative 4).

### Decision 5 — Explicit non-changes (the fence)

- No QP objective term, no weight, no floor changes (S675 mandate).
- `.buildMatingUnitForest()`, `.forestComponents()`/`.packComponents()` (family order stays
  kinship2's ped order — deliberately *not* optimized, Decision 6 of the QP plan and S667),
  Tier-1 BJL internals, `sweepMinSepBackstop()`, the S666 conditional shift, Tier 2/3,
  Decision-1 seeding, `.solveJointQP()`, `.addRectilinearWaypoints()`,
  `.resolveEdgeNodeCollisions()`: **all unchanged code.**
- Row policy (row = generation) unchanged; every node keeps its row.
- No new export, no new node kind or reserved prefix, no new package dependency.
- No UI control — the pass is unconditional engine behaviour like the QP and the S666 rule
  (Open Question 3 records the kill-switch alternative).
- Sibling order *within* sibships and a polygamous parent's *unit* order are not touched
  (S686 §2 measured the within-sibship lever ≈ empty; unit order follows children's mean,
  `:1261-1267`, unchanged).

### Data flow

```
ped, forest ──► .positionMatingUnitForest()  [per component]
                  │  founderIds / b1Ids / orphanChildIds ──► rootIds (ped row order)   :961-983
                  │
                  ├─► .orderRootSubtrees(rootIds, childrenOf, matingUnits, duplicates, minSep)   NEW
                  │      k ≤ 2 or no cross-root connector ──────────────────────► rootIds (identity)
                  │      Tier-1 BJL (incoming order) ─► blocks, connector offsets
                  │      RCM seed ─► local search (≤ 20 sweeps) ─► strictly better? ─► new order / identity
                  │
                  ├─► .buildForestChildrenOf(rootIds) ─► Tier-1 BJL (final order)      :985-988  unchanged
                  ├─► backstops · S666 shift · Tier 2 · Tier 3 · Decision-1 seeding    :990-1312 unchanged
                  └─► .solveJointQP(provisionalPos, …)                                 :1327     unchanged
```

### Failure-mode analysis

| Situation | Behaviour |
|---|---|
| ≤ 2 roots, or no connector between different roots (all 5 packing fixtures) | early return, identity, zero cost |
| connector graph disconnected within the component | RCM visits each connected piece in turn (min-degree start each time); unconnected roots trail in current order; local search can still move any block |
| many roots (issue #138 cap) | cost is O(k² · m) per sweep; `maxSweeps` bounds it; Open Question 4 measures the cap case and names the fallback (windowed moves) |
| exact proxy ties between orders | strict `− 1e-9` acceptance on exact-arithmetic values → incumbent kept; identical on every platform |
| proxy improves but the true layout does not (Track C) | order changes, layout provably identical to tolerance (§Evidence 4); disclosed; Open Question 5 |
| a root whose subtree has no rendered member, a duplicate at an orphan unit (anchor `NA`) | contributes no block width / no connector; never an error |
| `rootIds` contract violated (NA/empty) | `stop()` with the same wording style as `.buildForestChildrenOf()` |

---

## Rationale

- **It changes the one input the defect lives in, at the one line where it enters.** Learning
  739 established every order lever reduces to root order; this design reorders `rootIds`
  where it is assembled and nothing else — the same "fix it where it lives" separation the
  QP plan (Decision 1) and the provisional-order design drew.
- **Zero blast radius on ids and structure, by construction not by measurement.** The
  S686 handoff's largest anticipated cost (`__union_N` renumbering → pin and screenshot
  churn) is shown to be a non-issue for root-only reordering (§Context), and the in-engine
  placement removes even the orphan-child exception.
- **Determinism is designed in, not tested in.** RCM + exact Tier-1 arithmetic makes the
  ordering decision bitwise reproducible across the 3-OS CI matrix; the two measured
  upgrades (spectral seed, QP calibration) each buy ~3 points of ink at the price of a
  platform-dependent ingredient — recorded, not taken.
- **Cost is bounded where the engine is already expensive.** +0.3 s on Real 375 against a
  1.86 s layout, and *no* second QP — the one stage that scales cubically toward issue
  #138's cap.
- **Honest ceiling.** −27.8% ink / −41% chord×chord crossings / census cCurved −16% on the
  real fixture, not the −33% ink / −36% cCurved S686 reported; the difference is the price
  of Decisions 2–3, itemized above and in §Evidence 7, and the owner can buy most of it
  back at the PRE-RED gate (§Alternatives 1–2) — at the cost of determinism guards
  (spectral) or a second QP (full calibration), and, for spectral, +5 off-centre unions
  and +19 jog corridors. The dome thins, it does
  not vanish (S686 §5): mean connector span stays ~2,300 px; removing the rest needs routing
  or duplicate-policy work, out of scope.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why not (or: when to pick it) |
|---|---|---|---|
| **1. Calibrate from a full pass-1 layout (QP-solved positions)** | −31.0% (current seed) / −33.5% (spectral) vs −27.8%: **+3 points** | a second `.solveJointQP()` per component (+1.4 s on Real 375, 94% of positioning; ~cubic toward the 1,500-node cap); QP output carries compiler/FMA-level jitter that a near-tie ordering decision can amplify into a platform-dependent layout | Rejected as the default. **Owner upgrade path**: if the extra ink matters more than render time on the app's actual pedigree sizes, Phase 1's gate can adopt it — the pass would then take `provisionalPos`-style positions instead of `tier1X`; nothing else in the design changes. An adaptive rule (QP calibration below N variables, Tier-1 above) is possible but adds a second code path — Open Question 2. |
| **2. Spectral (Fiedler-vector) seed** | +3 points of ink at either calibration (Tier-1: −31.0%); **census cCurved −33% vs RCM's −16%** — twice the dome thinning, close to S686's converged −36%; d 0; S686's own seed | `eigen()`/LAPACK: sign ambiguity, degenerate λ₂ when the connector graph is disconnected within a component (2 connector-less roots exist on Real 375, though not in the big component) or has automorphic roots, cross-platform near-tie flips; each needs a guard (per-subgraph Fiedler, canonical sign, spectral-gap test, coordinate rounding + current-position tie-break). Census: **b 12 → 17** (+5 off-centre unions), **jogs 95 → 114** (+19) | Rejected as the default for determinism and the b/jog regressions. **Owner upgrade path** with all four guards if the dome metric is the priority; the pinned Real-375 suite across 3 OSes is the detector if a guard is missed. |
| 3. Iterate Tier-1 calibration to convergence | none measured | **diverges** (§Evidence 3: +9.3% worse than baseline at round 2) | Rejected on measurement. |
| 4. Iterate QP calibration to convergence (S686's loop) | −33% converged | 3× QP; one round already captures 94% of it | Rejected; Alternative 1 is its one-round form. |
| 5. Realize the order as a **ped-row permutation** in `makePedigreeMatingLayout()` (Shape A as S686 measured it) | zero engine edits — a pre-processing step | permutes `ped` → `nodes` row order changes for every caller; orphan-child roots (issue #154) *would* renumber units; a founder-row permutation is only *provably* equivalent to a `rootIds` reorder because of the §Context analysis — the in-engine form makes that equivalence unnecessary | Rejected; Decision 1 is the same lever at its source. |
| 6. **Shape B** — exported utility that reorders a `ped` before rendering | zero engine risk | users must know to call it; the Shiny tab needs its own integration decision; every consumer that renders from `ped` order (tooltips, tables) sees a permuted frame | Recorded fallback (S686); not needed once Decision 1 shows the engine form is byte-safe. |
| 7. Evaluate several seeds by the **true** post-QP objective and keep the best | picks right when the proxy mis-ranks (the proxy chose current over RCM on Real 375 though RCM was truer) | one QP solve per candidate | Rejected on cost; the proxy is the arbiter, disclosed. |
| 8. Barycenter / kinship2 `autohint` analogue | kinship2 precedent | measured worse every iteration (S686 §4) | Rejected on S686's measurement; not re-run. |
| 9. True-objective acceptance gate (adopt the new order only if the post-QP ink improves) | monotone by construction; bitwise identity on Track C | needs the second QP (Alternative 1's cost) for a benefit Track C already has to tolerance | Rejected; Open Question 5 names the cheap guard if bitwise identity is ever required. |
| 10. Also optimize **component** (family) order in `.packComponents()` | connectors never cross families (0 cross-component connectors by definition), so no ink to gain | changes kinship2's own family order (S667's verified parity) | Not applicable — recorded so no session re-litigates it. |

---

## Evidence-Based Inventory

Grep- and read-based, this session, against `master` at `4f9f4783` (S688 claim).

**Code the design changes**

```
R/makePedigreeDiagramData.R:983-985   rootIds assembly → NEW .orderRootSubtrees() call → .buildForestChildrenOf()
R/makePedigreeDiagramData.R           NEW internal .orderRootSubtrees() (~120-160 lines incl. roxygen), placed
                                      beside .nonAnchorNodeResolver()/.forestComponents() (the other pure
                                      structural helpers), or in its own R/orderRootSubtrees.R beside
                                      R/positionTreeApportion.R (the implementing session's call; the
                                      latter matches the "standalone, pedigree-agnostic engine file" precedent)
tests/testthat/test_orderRootSubtrees.R   NEW (Phase 1)
```

**Code the design must NOT change (read this session; the pass only consumes them)**

```
R/makePedigreeDiagramData.R:399-603   .buildMatingUnitForest()  (unit/dup numbering :426-447, :556-582)
R/makePedigreeDiagramData.R:634-738   .forestComponents() / .subsetForest() / .packComponents()
R/makePedigreeDiagramData.R:873-882   per-component recursion (the pass inherits per-component scope from it)
R/makePedigreeDiagramData.R:897-907   childrenOf() closure (passed into the pass)
R/makePedigreeDiagramData.R:985-1328  Tier 1 … Decision-1 seeding … .solveJointQP() call
R/makePedigreeDiagramData.R:1416-1588 .solveJointQP()
R/positionTreeApportion.R:238-277     .positionTreeApportion(), .buildForestChildrenOf() (called by the pass)
R/modPedigree.R:642                   the app's single call site — unchanged signature
```

**Literal `__union_N` / `__dup_<id>_N` pins — do NOT move (ids stable, §Context)**

```
tests/testthat/test_positionMatingUnitForest.R:1422,1450,1477   (small synthetic fixtures — not Real 375)
tests/testthat/test_positionMatingUnitForest.R:2952-2953        disclosed set __union_97/114/128/130/137/179/228
                                                                 (ids stable; WHICH units are off-centre may change —
                                                                 the census (b) count is the invariant, not the id list)
tests/testthat/test_buildMatingUnitForest.R:31,39                hand-built expectations, forest-only
tests/testthat/test_makePedigreeMatingLayout.R:314               __dup_8LKBV9_1 (id stable; its connector's x-ordered
                                                                 from/to may swap if positions cross — re-derive)
tests/testthat/test_resolveEdgeNodeCollisions.R:355              __dup_28XSME_1 (id stable; roundness bump depends on
                                                                 same-row obstacles — re-derive)
tests/testthat/test_solveJointQP.R:496,539,546-547               hand-built fixtures, direct QP calls — unaffected
```

**Real-375 numeric pins to RE-DERIVE (positions change; ids do not)** — every
`system.file(..., "obfuscated_rhesus_mhc_ped.csv")` load in a positioning-dependent test:

```
tests/testthat/test_positionMatingUnitForest.R  :532 :601 :906 :1089 :1194 :2008 :2074 :2419 :2576 :2731 :2772
                                                 :2825 :2863 :2927 :2985   (15 loads; the S675/S679/S683/S685
                                                 measured-value pins, the class-(b) disclosed-residual set, the
                                                 P49ZD1 drop-jog pin :2978, the zero-crossing/never-outside-span
                                                 structural guards :2819/:2855 — the latter must still PASS, they
                                                 are invariants not measurements)
tests/testthat/test_resolveEdgeNodeCollisions.R :326 :397 :479 :643 :930   (:479 "dramatically reduces …" pinned
                                                 counts; :930 the S685 zero-corridor-disc-violations guard — an
                                                 INVARIANT that must hold on the new order, c2 must stay 0)
tests/testthat/test_makePedigreeMatingLayout.R  :323 :506 :644                (:598 __proj_/waypoint count pins)
tests/testthat/test_addRectilinearWaypoints.R   :541 :596 :680                (:749 D1 bar-overlap pin)
tests/testthat/test_makePedigreeMatingLayout.R:1113, test_resolveEdgeNodeCollisions.R:712   twin fixture variants
```
Position-agnostic Real-375 users, expected unchanged: `test_buildMatingUnitForest.R` (4
loads, forest only), `test_comparePedigreeStructure.R:606,980` (structure), the `test-e2e-*`
suites (count-based: 56 marked edges, zero `throw` logs, colours — `test-e2e-pedigree-
module.R:355`), `helper-live-render-positions.R` (live vs R-side positions, self-consistent).

**Reference images and screenshots**

```
vignettes/articles/kinship2-fidelity-validation-img/trackB-nprc-{full,shrunk}.png   identity → unchanged
vignettes/articles/kinship2-fidelity-validation-img/trackC-nprc-{direct,rectilinear}.png   layout identical → unchanged
the 5 Diagram-tab screenshots (S683/S685 digest scripts scratchpad/s68{3,5}_screenshotDigests.R:
  trims of Real 375 — legend+rectilinear, show_names, twin connectors, …)              positions WILL change →
                                                                                        regenerate in Phase 3, owner-reviewed
data-raw/pedigreeDrawingErrorCensus.R                                                   unchanged; re-run as the gate
```

**Reserved prefixes** (`:411`): `__union_|__dup_|__drop_|__bar_|__proj_` (+ `__jog_`,
`__super_root__`) — the design adds none.

---

## Migration Path

Each phase is a separate implementation session, full RED→GREEN→REFACTOR per `CLAUDE.md`'s
TDD contract, PRE-RED-gated by `AskUserQuestion` (which also ratifies this design's
decisions — and is where Alternatives 1/2 are chosen or declined). **Do not bundle phases**
(FM #18). Expected numbers are this session's measurements; the implementing session
re-measures (Learning 720's reflex) — a materially different number is a red flag, not an
amendment.

### Phase 1 — `.orderRootSubtrees()` standalone, not yet wired

**What DONE looks like:** the new internal function implementing Decisions 2–4 with its own
test file, **not** called from `.positionMatingUnitForest()`. RED should assert directly:
(i) identity on Track B full/shrunk, D1, D2, D3 (`identical()`); (ii) Track C's order
`X,P1,W` (or identity, if the owner picks Open Question 5's guard); (iii) on Real 375's
50-root component: the returned order is a permutation, the proxy strictly improves, and
the result equals a pinned order (the RCM order printed by `scratchpad/s688_realize_rcm.R`
is the reference); (iv) determinism — two calls identical; (v) `maxSweeps` respected on an
adversarial input; (vi) the `stop()` contract; (vii) k ≤ 2 / no-connector early exits.
**Verification:** `devtools::test(filter = "orderRootSubtrees")`; `lintr::lint_package()` 0
on the new file (package loaded first, Learning 224); the pass's own wall time on Real 375
reported in the handoff (target ≤ 0.5 s).
**Session boundary:** close out here.

### Phase 2 — Wire in, re-derive, census, visual review

**What DONE looks like:** the one-line insertion at `:983-985`; the Real-375 pins in
§Inventory re-derived against the new engine output (not assumed); the structural
invariants (:2819 never-outside-span, :2855 no same-row crossing, :930 zero corridor-disc
violations) still passing *as invariants*; the five packing fixtures `identical()` to
pre-change output and Track C `expect_equal`; owner visual review of a before/after Real
375 render pair (S666/S667/S675 precedent — an engine-output change needs an explicit visual
approval, not just green tests).
**Verification:** census re-run (`Rscript data-raw/pedigreeDrawingErrorCensus.R`) — Real 375
expectations from this session's harness run (§Evidence 7): under the recommended RCM seed
≈ (jogs 93, b 8 of which 2 dust, c1Pre 6, cCurved 1,667, d 1 — the `__dup_SLN0TF_2`/`SLN0TF`
pair); under spectral ≈ (jogs 114, b 17, c1Pre 8, cCurved 1,343, d 0). **Invariants** —
a defect if they move: a / c1Post / c2 / e / f = 0 (QP floors, repair pass, S685 band, S678
policy, family packing). **Order-sensitive, reported not gated:** b, d, jogs, c1Pre, cCurved
— compare to the row for the seed the gate chose; a materially different number is a red
flag. Track B/C/D rows byte-identical to the committed CSV. Full clean regression + lint 0.
**Session boundary:** close out here.

### Phase 3 — Docs & follow-ups (may fold into Phase 2's close-out if scope allows)

`NEWS.Rmd` plain-language entry (S628 criterion: e.g. "The pedigree diagram now places
related founder families next to each other, so the long curved lines that connect an
animal's repeated appearances are about a quarter shorter and cross each other less
often"); regenerate the 5 Diagram-tab screenshots (S683/S685 digest scripts, owner-reviewed);
`a2interactive.Rmd` needs nothing (no new export or parameter — the deferred checklist does
not fire); `BACKLOG.md`: replace the Shape-A item per the completed-item convention (record
here + `CHANGELOG.md`, no `[x]`); record Open-Question dispositions.

---

## Impact Analysis

### What changes
- The left-to-right order of founder subtrees within each multi-root component, hence
  every node's final `x` on pedigrees with cross-root duplicate connectors (Real 375: all 50
  big-component roots may move).
- Connector ink −27.8%, chord×chord crossings −41%, chord×straight −35% (Real 375, RCM);
  census jogs 95 → 93, b 12 → 8, c1Pre 10 → 6, cCurved 1,996 → 1,667 (−16%), d 0 → 1
  (spectral, if chosen: cCurved −33%, b 17, jogs 114, d 0 — §Evidence 7).
- The Real-375 numeric pins and the 5 Diagram-tab screenshots.
- Layout time +≈0.3 s on Real 375 (1.86 → ≈2.2 s).

### What does NOT change (explicit scope boundary)
- Every id (`__union_N`, `__dup_*`), the forest tables, the component partition, the
  `nodes`/`edges` row order, every `y`/row.
- The five packing fixtures (byte-identical) and Track C (identical to tolerance).
- Signatures/contracts of every existing function; the QP formulation; the waypoint/jog
  layers; the app's call site and UI.

### What might break (risk assessment)
- **A pin that encodes "which unit" rather than "how many".** `test_positionMatingUnitForest.R:2952`'s
  disclosed class-(b) set names 7 unions; the *count* (12, with 5 dust rows) is the
  invariant, the membership may shift with order. Phase 2 re-derives membership and keeps
  the count assertion.
- **The structural guards must be re-run as tests, not assumed.** c2 = 0 (S685 band),
  c1Post = 0 (repair pass), never-outside-span and no-same-row-crossing are QP/repair-layer
  guarantees and held in every census run this session; class (b) is **not** one of them
  (§Evidence 7 — it moved 12 → 8 under RCM and 12 → 17 under spectral), so the disclosed
  class-(b) set's *count* is a measured expectation to re-derive, never an invariant to
  defend.
- **One new class-(d) pair under RCM** (`__dup_SLN0TF_2` adjacent to `SLN0TF`): the
  kinship2 `alignped3` collapse-when-adjacent refinement remains undesigned (provisional-
  order design, Open Question 1, disposition NOT PURSUED); Phase 2's visual review decides
  whether one adjacent pair warrants reopening it.
- **Scale.** At issue #138's cap the local search is O(k² · m · sweeps); `maxSweeps` bounds
  it but a 200-root component could still cost seconds (Open Question 4).
- **Proxy mis-ranking.** The proxy preferred the current-order search result over RCM's on
  Real 375 although RCM was truer; Decision 3 therefore uses RCM as the *only* seed (no
  current-order search to out-vote it) and keeps the incoming order only via the acceptance
  test. If a future fixture shows the proxy adopting a truly-worse order, Alternative 9 is
  the remedy.

---

## Verification Plan

- **Census as the acceptance gate** at Phase 2 (its own Recommendation 2), expectations
  below; byte-identity of Track B full/shrunk, D1–D3 as a hard invariant (`identical()` on
  positions), Track C `expect_equal`.
- **Structural RED assertions** (Phase 1): permutation property, strict proxy improvement,
  determinism, early exits, sweep cap — direct tests of the contract, cheaper to debug than
  census deltas.
- **Cross-platform determinism** is verified by the existing 3-OS `R-CMD-check.yaml` matrix
  running the re-derived Real-375 pins — a platform-dependent order would fail there before
  merge (Learning 547's lesson applied: *look* at the run).
- **Owner visual review** before Phase 2 close-out (before/after overview + a meso crop, as
  S686 delivered), per the standing visual-evidence directive.
- **Full clean regression + lint** at each phase boundary (`CLAUDE.md` Build/Test/Verify).

### Census expectations

§Evidence 7 is the table (this session's run of S686's byte-faithful harness copy on each
realized order; logs and findings CSVs in `scratchpad/s688_census_*`). The invariant/
reported split in Phase 2's verification line is the rule for reading it.

---

## Open Questions for a Future Session

1. **Spectral seed upgrade** (Alternative 2): worth +3 points of ink on Real 375. If the
   owner wants it, implement with all four guards and add a cross-platform RED assertion
   (pin the Real-375 order; CI's 3 OSes are the detector).
2. **QP-calibration upgrade for small pedigrees** (Alternative 1): an adaptive rule
   ("calibrate from the QP-solved pass-1 when the component has < N QP variables, else
   Tier-1") would give −31/−33.5% where the second QP is cheap. Two code paths; decide
   after the app's real pedigree sizes are known.
3. **Kill switch.** An internal `getOption("nprcgenekeepr.orderRootSubtrees", TRUE)` would
   let tests pin baseline vs ordered without a spike and give a field escape hatch; it also
   adds a test-matrix dimension and a permanent option. Recommended: none — the pass is
   unconditional like the QP and S666; revisit only if Phase 2's visual review finds a
   pedigree shape the pass makes worse.
4. **Scaling at the 1,500-node cap.** Time the pass on a synthetic single component with
   ~200 roots and ~500 connectors; if > 1 s, restrict moves to a window (`|i − j| ≤ w`) or
   vectorize the swap evaluation. Not measured here (no such fixture exists).
5. **Track C bitwise identity.** Output-identical to 1.5e-8 today; if a digest-style check
   ever needs `identical()`, the cheapest guard is "skip components with < 4 roots" (Track C
   has 3; Real 375's has 50) — arbitrary but harmless. Not recommended pre-emptively.
6. **Mean span ceiling.** Ordering leaves ~2,300 px mean connector span (S686 §5); the
   remaining dome is a routing / duplicate-policy question, a separate design.

---

## Appendix — reference algorithm (measurement instrument, not shippable code)

As measured in `scratchpad/s688_m5.R` (`structFacts()`, `tier1Xof()`, `blocksFrom()`,
`rcmOrder()`, `optimizeRoots()`); the implementing session re-derives under TDD.

```r
## inputs: roots (incoming order), blockWidth[roots], conn(rootDup, rootReal, offDup, offReal), minSep
k <- length(roots); if (k <= 2L) return(roots)
sub <- conn[conn$rootDup %in% roots & conn$rootReal %in% roots & conn$rootDup != conn$rootReal, ]
if (nrow(sub) == 0L) return(roots)
proxy <- function(o) {
  lefts <- cumsum(c(0, head(blockWidth[o] + minSep, -1L))); names(lefts) <- o
  sum(abs((lefts[sub$rootDup] + sub$offDup) - (lefts[sub$rootReal] + sub$offReal)))
}
## reverse Cuthill-McKee on the connector graph W (deg = number of connected roots)
rcm <- function(roots, W) { ... min-degree start, BFS by ascending degree, ties by current position,
                            unconnected roots as their own trivial BFS, reverse the visit order ... }
o <- rcm(roots, W); val <- proxy(o); sweeps <- 0L; improved <- TRUE
while (improved && sweeps < 20L) {
  improved <- FALSE; sweeps <- sweeps + 1L
  for (i in 1:(k-1)) for (j in (i+1):k) { o2 <- swap(o, i, j); if (proxy(o2) < val - 1e-9) { o <- o2; val <- proxy(o); improved <- TRUE } }
  for (i in 1:k) for (j in 1:k) if (i != j) { o2 <- move(o, i, j); if (proxy(o2) < val - 1e-9) { o <- o2; val <- proxy(o); improved <- TRUE } }
}
if (val < proxy(roots) - 1e-9) o else roots        # prefer the incoming order unless strictly better
```

Block geometry (Decision 2): `tier1X <- .positionTreeApportion("__super_root__",
.buildForestChildrenOf(roots, childrenOf))`; block of root `r` = `subtree(r)` ∪ units
anchored in it ∪ duplicates at those units; `left/width` from `tier1X` of the subtree's real
members; connector endpoint x = `tier1X[real]` and `tier1X[anchor(unit(dup))]`, stored as
offsets from the block's left edge.
