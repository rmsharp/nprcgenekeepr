# Pedigree Diagram: Joint QP Solver (Option C) — Architecture & Migration Plan

**Date:** 2026-09-03 (Session 672) · **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
**Trigger:** `BACKLOG.md` Up Next item 1, **DECIDED S671, 2026-09-03: (C), a joint solver** — this
document is the named next step (S671/S670's own `next_steps`): spec the exact QP formulation
before any implementation session begins.
**Scope:** Design only. No `R/`/`tests/` package code changed this session — TDD RED/GREEN/REFACTOR
gates do not apply (owner-confirmed via `AskUserQuestion`, matching the S667–S671 audit/decision
precedent for this deliverable shape). `docs/planning/` placement matches ~25 prior
`pedigree-diagram-*-plan.md` documents for this exact problem domain (owner-confirmed via
`AskUserQuestion` this session, over the `ARCHITECTURE_WORKSTREAM.md`-generic `docs/architecture/`
alternative).
**Row-policy decision (owner-ratified via `AskUserQuestion` this session, resolving census
Finding #5):** **keep row = generation** (status quo) — see §Decision, Decision 5.

---

## Context

### Problem statement

`.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R:759–1529`, ~770 lines) computes every
rendered pedigree node's `x` position in **three strictly ordered tiers, each fully reconciled
before the next tier reads it** (its own docstring, :712–740), followed by five separate, mostly
one-directional, capped collision-avoidance passes. This is a **one-way data flow**: nothing a
later tier or repair pass computes ever revisits an earlier tier's already-frozen value to make
room for it. `docs/research/kinship2-alignped4-joint-positioning-mechanism-2026-09-03.md` (S670,
verified empirically, not just read) established this structure is the root cause of two of the
census's (`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02.md`, S668) three critical/moderate
findings and is why a bounded per-defect fix cascades (S669's spike: (c2) rose 3.4×) rather than
converging. kinship2's own `align.pedigree()` avoids this class of defect **by construction**: one
global constrained QP solve (`alignped4`, one `quadprog::solve.QP()` call) re-positions every
plotted point on every row simultaneously, subject to a **hard** per-adjacent-pair minimum-
separation constraint a QP solver cannot violate — verified live, 36/36 swept weight
configurations on 2 stress fixtures achieved a minimum same-row gap of exactly `1.000000`, never
less, at every setting.

This document specs the equivalent joint solve for THIS project's own node set (real individuals,
`__dup_*` duplicate placeholders, and `__union_*` mating-unit dots — a concept kinship2 has no
analogue for at all) and radius-based symbol sizes (25 px individual/duplicate, 6 px union dot;
kinship2's own floor is uniform).

### Constraints

- **No canvas width bound.** kinship2's QP includes `first >= 0`/`last <= width-1` row-width
  constraints (a base-R plotting-device requirement). This project's diagram renders via
  `visNetwork`, which auto-fits to content — there is no fixed canvas width anywhere in the current
  engine (confirmed: no `width` constant/parameter exists in `.positionMatingUnitForest()`). The
  QP formulation below **omits** the width-bound constraint entirely — a deliberate, disclosed
  divergence from kinship2, not an oversight.
- **`quadprog` license.** `quadprog`/`kinship2` are both `GPL (>= 2)`; this project is `MIT + file
  LICENSE` (`DESCRIPTION:84`). An `Imports`-level runtime dependency on a GPL package from an MIT
  package is standard, accepted CRAN practice — verified S671, not a blocker.
- **Scale.** The bundled real fixture (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`) has
  375 individuals / 237 mating units / 102 duplicates (census Scoreboard). Issue #138 already caps
  full-colony rendering at 1,500 nodes (a deliberate, separate scope limit) — this design's
  performance verification target is that cap, not unbounded scale.
- **Existing pinned test surface.** `.positionMatingUnitForest()` has exactly 2 production call
  sites (`R/makePedigreeDiagramData.R:804` — the recursive per-component self-call, and `:1682` —
  from `makePedigreeMatingLayout()`) but 6,635 lines across 4 test files pin its exact numeric
  output (`test_positionMatingUnitForest.R` 3,494 lines, `test_makePedigreeMatingLayout.R` 1,662,
  `test_addRectilinearWaypoints.R` 861, `test_resolveEdgeNodeCollisions.R` 618 — grep-confirmed,
  §Evidence-Based Inventory). This bounds the size of Phase 3 below, not the design itself.

### Current state (from direct reading of `R/makePedigreeDiagramData.R:389–1529`, this session,
not from `SESSION_NOTES.md`'s summary)

| Stage | What it does | Fate under this design |
|---|---|---|
| `.buildMatingUnitForest()` (:389–565) | D1/D2: builds `matingUnits` (`id`,`sire`,`dam`,`anchor`,`nonAnchor`,`gen`), `duplicates` (`id`,`realId`,`matingUnitId`), `childEdges` (`from`,`to`) | **Unchanged** |
| `.forestComponents()`/`.packComponents()` (:596–697) + recursive per-component call (:801–810, S667) | Partitions weakly-connected families, lays each out alone, rigidly packs left-to-right | **Unchanged** (§Alternatives Considered, Alternative 2) |
| Tier 1: `.positionTreeApportion()` (:915, `R/positionTreeApportion.R`) | Genuine-tree BJL apportionment → `tier1X` | **Unchanged** |
| `sweepMinSepBackstop()` (:933–946, called twice) | Gen-grouped minSep backstop on `tier1X` ties | **Unchanged** |
| S666 conditional-shift (:948–1019) | Shifts a qualifying unit's anchor/children so the union midpoint matches the true parent midpoint | **Unchanged** (still needed to produce a sane *provisional* order — see §Decision, Decision 1) |
| Tier 2: union-x formula (:1036–1042) | `unitX[u] <- mean(tier1X[children])` | **Repurposed**: kept verbatim, output now used only to fix provisional row order (§Decision, Decision 1) — no longer the *final* union `x` |
| Tier 3: `derivedX()`/`b1AnchorRelativeX()` (:1071–1084) | B1 formula: anchor ± 1 unit; B3 (duplicate) formula: `unitX + minSep*0.4` | **Repurposed**, same reason |
| `.deCollideIndividualPoints()` (:1132–1206) + 2 call sites | Capped bidirectional exact-tie search, B1 vs. genuine individuals | **Replaced** by the QP (§Decision, Decision 2) |
| B1-vs-unrelated-individual proximity pass (:1294–1338, S661/S662) | Capped push, radius-based (`individualClearance`) | **Replaced** |
| Track 7 Phase 2 union sweep (:1340–1427, S648/S649) | Capped bidirectional push, union vs. individual/union (`unionClearanceIndividual`/`unionClearanceUnion`) | **Replaced** |
| Duplicate de-collision + Track 7 Phase 4 (:1429–1515, S654/S658) | Capped unidirectional push, duplicate vs. union/individual | **Replaced** |
| `.addRectilinearWaypoints()` D2 dogleg (:2167–2236) | Projects an off-row mate onto her union's row for rendering | **Unchanged** (§Decision, Decision 5) |
| `.resolveEdgeNodeCollisions()` (:2414+) | Jogs a same-row edge that crosses an unrelated symbol | **Unchanged**, expected to fire less often (§Impact Analysis) |

---

## Decision

Replace the five collision-avoidance/de-collision passes (deleted-column rows in the table above)
with **one joint `quadprog::solve.QP()` call per weakly-connected component**, run after Tier
1/2/3's existing formulas have produced a *provisional* position/order for every node, honoring
that order as a fixed input the way kinship2's Phase A output feeds its own Phase B.

### Decision 1 — Two phases, exactly mirroring kinship2's own structure

- **Phase A (unchanged, in full):** everything currently in `.positionMatingUnitForest()` through
  the existing Tier 2/Tier 3 formula computation (:759–1091) — Tier 1 BJL, both
  `sweepMinSepBackstop()` calls, the S666 conditional-shift, Tier 2's `unitX <- mean(children)`,
  Tier 3's `derivedX()` — runs **exactly as it does today, byte-for-byte**. Its output
  (`provisionalX`, one value per node) is used for **two purposes only**: (a) it already IS the
  final `x` for genuine Tier-1 individuals feeding the QP's row/order fixing (kinship2's Phase A
  plays the identical role — an order-only, sequential, heuristic pass); (b) for union/B1/duplicate
  nodes, it fixes **provisional left-to-right rank within their row**, and nothing else — its
  numeric magnitude is discarded once Phase B runs.

  This is a deliberate reuse, not a coincidence: S670's report (§4, "Carries over unchanged")
  already established Tier 1 is not the cascade's cause. Extending that finding, Tier 2/Tier 3's
  own *formulas* (as opposed to the *collision-avoidance passes bolted onto them*) are pure,
  order-preserving-in-the-overwhelming-common-case functions of already-fixed values — reusing them
  for provisional rank avoids inventing a second, parallel order-determination mechanism.

- **Phase B (new):** for each weakly-connected component (§Alternatives Considered, Alternative 2),
  one `.solveJointQP()` call takes `provisionalX` plus `matingUnits`/`duplicates`/`childEdges` and
  returns the FINAL `x` for every node in that component, replacing every value Phase A computed
  for union/B1/duplicate nodes (genuine Tier-1 individuals' `x` values may also move — the QP
  re-solves everyone simultaneously, exactly like kinship2's own `alignped4`).

### Decision 2 — Variable set (translation layer, item 1 of S670 §4's costed list)

One QP variable per node in `.positionMatingUnitForest()`'s own current output row set — **no
change to which nodes exist**, only to how their `x` is computed:

```
V = genuineIds        (real individuals reached by Tier-1 recursion; names(tier1X))
  ∪ unitIds            (every mating unit with >= 1 real child; xDerivableUnits$id)
  ∪ b1Ids               (free-pass individuals, Tier 3's B1 formula domain)
  ∪ dupIds              (duplicate placeholders, forest$duplicates$id)
```

`varIndex <- setNames(seq_along(V), V)` is the flat-index join key `myid` plays in kinship2's own
`alignped4`. `V` is exactly `c(genuineIds, unitIds, tier3Ids)` — the vector
`.positionMatingUnitForest()`'s current return statement already builds (:1522–1523). Node **kind**
for constraint/penalty purposes has two values, matching the render layer's own two symbol sizes:
`"union"` (id in `unitIds`) and `"individual"` (everything else — genuine, B1, and duplicate nodes
all render as the same 25 px circle/square, and the current code already treats them identically
for clearance purposes: `individualClearance` is used uniformly across genuine/B1/duplicate
collision checks, :1270/:1311/:1383/:1484).

### Decision 3 — Constraints (item 3 of S670 §4's costed list: radius-based `minSep` generalization)

For each row (grouped by `gen`, unchanged from today — §Decision 5 on why `gen` stays the row key),
sort that row's node ids by `provisionalX` (ties broken by id, `method = "radix"` — the same
tie-break `sweepMinSepBackstop()` already uses, :937) to fix a **left-to-right chain order**. For
each adjacent pair `(i, i+1)` in that fixed order, add one linear inequality:

```
x[i+1] - x[i] >= minSepFor(kind[i], kind[i+1])
```

`minSepFor` generalizes kinship2's uniform `1` to this project's own render-layer constants —
**the same numeric values the current collision-avoidance passes already use** (:1262–1270),
repurposed from soft, capped-push thresholds into hard QP constraint right-hand sides, no new
constants invented:

| Pair kind | Value | Current constant |
|---|---:|---|
| individual–individual, individual–duplicate, duplicate–duplicate | 0.4167 | `individualClearance` |
| individual–union, duplicate–union | 0.2583 | `unionClearanceIndividual` |
| union–union | 0.1 | `unionClearanceUnion` |

This is `quadprog`'s `Amat`/`bvec`: one column of `Amat` per constraint row, `+1` at
`varIndex[i+1]`, `-1` at `varIndex[i]`; `bvec` entry = the table lookup above. `meq = 0` (every
constraint is an inequality, matching kinship2 exactly — no equality constraints).

**No row-width bound** (§Context, Constraints) — kinship2's 2-per-row width constraints are
dropped entirely, a disclosed divergence.

#### Decision 3 — AMENDED (Session 675, Migration Path Phase 3, owner-ratified via `AskUserQuestion`)

The table above is **superseded**. Phase 3's first real-fixture render under those floors showed
why: the QP objective (Decision 4) pulls every adjacent pair down to its floor, and the floors
above are the render layer's *symbol-tangent* distances — so 684 of the real 375 fixture's 705
adjacent pairs landed at exactly the floor, symbols touching and labels overlapping into a
continuous band (measured S675: 90% of adjacent individuals at exactly 50 px centre-to-centre;
width 6,676 px). The census's class (a) also read 90 "overlaps" that were sub-microscopic
(≤ 1.3e-6 px) `solve.QP()` precision shortfalls at its 1e-9 px epsilon, not geometry. The
constants were designed as *collision thresholds* for the old capped-push passes (fire only when
something is already too close), never as the typical spacing — that role belonged to Tier 1's
`minSep = 1`, which Decision 1 stopped applying.

**Amended floors, keyed to the engine's own `minSep` (1 raw unit = 120 px, kinship2's own uniform
`alignped4` floor) — no new constant introduced:**

| Pair kind | Value | Source |
|---|---:|---|
| individual–individual, individual–duplicate, duplicate–duplicate | `minSep` = 1.0 | `.positionMatingUnitForest()`'s Tier-1 spacing; kinship2's uniform floor |
| individual–union, duplicate–union | `minSep / 2` = 0.5 | the S666 qualifying-pair geometry: mates 1.0 apart, dot centred |
| union–union | `minSep / 4` = 0.25 | derived |

`.solveJointQP()` takes `minSep` as an argument (default 1) and derives the three floors from it;
`.positionMatingUnitForest()` passes its own `minSep`. Measured consequences on the real fixture
(S675): census class (a) 90 → **0** with zero tangent pairs (no exact-floor snap needed — a 70 px
margin absorbs solver precision), width 6,676 → 13,680 px (+32% vs the pre-QP engine's 10,395),
class (b) unchanged at 46/47 and the jog-repair count unchanged at ~267 (both are order-driven,
see the Phase 3 record below), and the small packing fixtures (Track B shrunk, D1–D3) return to
**bit-exact agreement with kinship2's own `align.pedigree()` values** (the S665/S667 targets), which
the tangent floors had broken. Alternatives measured and shown to the owner as renders before the
decision: keep tangent + exact-floor snap (legibility unchanged), an intermediate 0.667/0.375/0.15
(9,860 px, labels tight), and this parity set.

The original constants stay in force where they belong — `.resolveEdgeNodeCollisions()`'s same-row
collision thresholds are untouched.

### Decision 4 — Objective (items 2 and "duplicate-proximity" of S670 §4's costed list)

One penalty row per term below, accumulated into `pmat` exactly as kinship2's `alignped4` builds
its own (each row later squared via `t(pmat) %*% pmat`); `e[id]` denotes the unit basis vector at
`varIndex[[id]]`. `Nnode(u)` resolves a unit's non-anchor party to its actually-*rendered* node —
her own genuine/B1 node, or the matching `__dup_*` node if this occurrence is a duplicate — reusing
the exact resolution `.addRectilinearWaypoints()`'s own D2 block already computes
(`dupKey`/`dupIdx`/`Nnode`, :2195–2197); extract it into a small shared helper both call, rather
than duplicating the lookup.

| # | Term | Applies to | Formula (one `pmat` row each) | Purpose |
|---|---|---|---|---|
| 1 | Spousal pull | every unit with a real anchor (`anchoredUnits`) | `sqrt(wSpouse) * (e[anchor] - e[Nnode(u)])` | kinship2's own `align[2]` term |
| 2 | Child centering | every real child of every unit with a real anchor | `sqrt(k^-alignChild) * (e[child] - 0.5·e[anchor] - 0.5·e[Nnode(u)])`, `k` = sibship size | kinship2's own `align[1]` term — pulls the child toward the TRUE parent midpoint, not the union dot |
| 3 | **Union centering (NEW)** | every unit with a real anchor | `sqrt(wUnion) * (e[u] - 0.5·e[anchor] - 0.5·e[Nnode(u)])` | Directly targets census Finding #1 (dot on the anchor's own symbol, 157/237 units) by giving the union dot its own free variable and its own centering pull, instead of deriving it post-hoc from values that already collapsed onto the anchor |
| 4 | **Duplicate proximity (NEW)** | every duplicate node | `sqrt(wDup) * (e[dupId] - e[realId])` | Targets census class (d) (duplicate near its real occurrence) — kinship2 does **not** solve this at all (S670 §3); mechanically identical shape to term 1, so building it costs nothing extra once the QP skeleton exists |
| 5 | Anti-degeneracy | one row, an arbitrary reference variable (e.g. `varIndex` of the widest row's first node) | `1e-5 * e[ref]` | Breaks translation invariance — `pmat` alone has a 0 unconstrained minimum at "shift everything by the same constant," and `solve.QP()` needs `Dmat` positive definite. Matches kinship2's own identical fix |

`pp <- t(pmat) %*% pmat + 1e-8 * diag(length(V))` — the same `1e-8` ridge kinship2 adds for
numerical strict positive-definiteness. Then:

```r
fit <- quadprog::solve.QP(Dmat = pp, dvec = rep(0, length(V)),
                           Amat = t(cmat), bvec = dvec, meq = 0)
```

(argument names/contract independently verified this session against the installed `quadprog`
1.5.8's own `args()`/`Rd` documentation — closing S670 report §6's open caveat #3: `solve.QP(Dmat,
dvec, Amat, bvec, meq=0, factorized=FALSE)`, minimizes `-d'b + 0.5 b'Db` subject to `A'b >= b0`,
first `meq` rows of `A` as equalities.)

**Weight defaults — starting values, not locked by this document:** `wSpouse = 2`, `alignChild =
1.5` (both = kinship2's own defaults, ported directly), `wUnion = 2` (same order as the spousal
term it structurally mirrors), `wDup = 1` (lower priority — a nice-to-have, not a hard
requirement), anti-degeneracy `1e-5`, ridge `1e-8` (both = kinship2's own values). Learning 678
already established that `align[2]`'s magnitude never changes the *achieved* same-row gap (it's
pinned at the constraint floor regardless) — this session's own §2.2 sweep extended that to
`align[1]` too, across 9 orders of magnitude. The RED phase (Migration Path Phase 1) must run the
equivalent sweep on the two **new** terms (`wUnion`, `wDup`) before locking their defaults, per that
same precedent — not assumed here.

### Decision 5 — Row policy: **keep row = generation** (resolves census Finding #5)

**Ratified via `AskUserQuestion` this session.** A non-founder mate whose own generation differs
from her union's stays on her **own** `gen` row (unchanged); the existing D2 dogleg
(`.addRectilinearWaypoints()`, :2167–2236) keeps rendering the projection to her union's row,
unmodified — this is a rendering/waypoint concern, entirely orthogonal to where the QP's own row
grouping (§Decision 3) draws its `gen` key from. **Reasoning:**

1. `findGeneration()`'s row assignment is a deliberate, already-shipped, tooltip-visible feature
   (census Finding #5's own text), not a defect — changing it is a product decision independent of
   the A-vs-C question, not a requirement of it.
2. S670 §2.1 already established Phase A/row-determination is **not** what removes the S669
   cascade — only Phase B (position values) is. Adopting kinship2's `kindepth(align=TRUE)` row
   policy is a second, independent behavior change with no bearing on this design's actual goal.
3. Blast radius: adopting kinship2's row alignment would move **every** non-founder mate across the
   whole colony (56 units on the real fixture alone) onto a different row — a strictly larger
   pinned-test/regenerated-image footprint than the position-value change this design is already
   scoped to, bundled into the same session for no structural benefit.
4. If wanted later, kinship2-style row alignment is a separable, independently-shippable follow-up
   (Finding #5's own text: "a row-policy decision that (C) would silently change" — this design
   makes that choice explicit rather than silent, satisfying the census's own Recommendation).

### Decision 6 — Disconnected components: keep `.packComponents()`, do not fold into one global QP

kinship2 solves ALL of a pedigree's weakly-connected families in **one** `alignped4()` call (S670
§2.2 Probe 1: the real 375 fixture's 5 families → still exactly 1 QP call, 520 variables/529
constraints). A structurally purer port would do the same — fold `.packComponents()`'s rigid
post-hoc shift into the joint QP's own per-row adjacency constraint (a family boundary is just
another adjacent pair with the same clearance rule). **This design does NOT do that** — see
§Alternatives Considered, Alternative 2, for why.

---

## Rationale

- **Removes the cascade by construction, not by tuning.** S670 §2 verified — empirically, not by
  inference — that a QP's hard linear constraints cannot be violated regardless of objective
  weighting; this is the direct mechanism by which S669's cascade (widen one spacing rule → break
  another) becomes structurally impossible: every position is re-solved simultaneously, so "make
  room for a wider gap here" and "keep everything else feasible" are the same optimization, not two
  one-directional passes that can conflict.
- **Reuses, rather than replaces, more than half the existing engine.** Tier 1 (BJL tree
  apportionment), `.forestComponents()`/`.packComponents()` (S667's disconnected-family handling,
  freshly shipped and bit-exact against kinship2 on 4 fixtures), `.buildMatingUnitForest()` (D1/D2),
  `.addRectilinearWaypoints()`/`.resolveEdgeNodeCollisions()` (rendering-layer waypoints/jogs) are
  **all unchanged**. Only the position-VALUE computation for union/B1/duplicate nodes and the five
  collision-avoidance passes are replaced.
- **Solves Finding #1 (dot on parent, 66% of production units) directly**, not as a side effect —
  the union-centering penalty (Decision 4, term 3) gives the union dot its own free variable and
  its own explicit pull to the true parent midpoint, the exact defect class S664/S666 had to
  specifically, narrowly correct for (60/237 "qualifying" units only) under the old one-way engine.
- **Closes a class the census's own kinship2 baseline does NOT close.** kinship2 has 145 duplicates
  vs. this project's 102 and no duplicate-proximity mechanism at all (S670 §3) — this design's term
  4 (Decision 4) is a genuine addition beyond a straight port, not required by parity with kinship2,
  costed as free once the QP skeleton exists.
- **Problem size is not a risk.** kinship2's own measured QP (520 vars/529 constraints on the real
  375 fixture) was "trivial" for `quadprog` (S670 §4). This project's own QP will be similarly
  sized — roughly `375 (individuals) + 237 (units) + 102 (duplicates) ≈ 714` variables (an estimate
  from the census's own per-fixture counts, not yet measured; Migration Path Phase 1's own RED run
  closes this with a direct measurement) — comfortably below where a dense active-set solver like
  `quadprog` becomes slow, and well inside issue #138's 1,500-node rendering cap.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|---|---|---|---|
| **1. (A) — narrower/gated bounded per-defect fixes** (the census's own untested variants: a tighter `qualifies()` gate, or a jog/collision-repair re-run after S669's two-constant change) | No new dependency; smaller diff; reuses 100% of the existing engine | S670 §2.3: both variants are still local, one-directional patches on the same one-way pipeline — they may shrink the S669 cascade's *size* but do not remove the *structural* reason it can recur with the next per-defect fix | **Already decided against** — S671, `AskUserQuestion`, before this document. Recorded here per the workstream template's completeness requirement, not reopened. |
| **2. Fold disconnected-component packing into one global QP** (matching kinship2's own literal mechanism exactly) | Structurally purer — no separate rigid-shift post-process; matches kinship2 1:1 | Reopens `.packComponents()`, freshly shipped S667 and independently verified bit-exact against kinship2 on 4 fixtures (Track B shrunk, D1–D3), for no measured defect — `.packComponents()` already achieves 0 family interleaving (census Scoreboard, class f, all 7 fixtures) | **Rejected.** No evidence this project's own family-packing is broken; re-deriving a just-verified subsystem inside an already Effort-L change adds risk with no offsetting benefit. Kept as a documented alternative, not built. |
| **3. Derive the union dot's `x` post-hoc** (mean of its two now-jointly-solved parent positions, rather than giving it its own QP variable — S670 §3's "simpler" option) | One fewer QP variable/penalty row per unit; simpler translation layer | Reintroduces exactly the class of "dot lands on a parent's own symbol" defect S666's conditional-shift rule had to specifically correct for the *current* engine (S670 §3) — nothing in the QP's own constraints would then prevent the derived point from coinciding with a parent | **Rejected.** Decision 4's own union-centering term is the same cost as any other penalty row (mechanically trivial) and removes the defect class by construction rather than needing a second correction pass layered on top, same mistake the current engine already made once. |
| **4. Adopt kinship2's spouse-row-alignment** (§Decision 5) | Matches kinship2 exactly; eliminates the D2 dogleg for 56 units | Changes a deliberate, shipped, tooltip-visible feature; bundles a second, independent behavior change into this session; larger blast radius than the position-value change alone | **Rejected**, owner-ratified via `AskUserQuestion` this session. See Decision 5. |

---

## Evidence-Based Inventory

Grep-based, run this session (not assumed from architectural memory), root of the package:

**Production call sites of `.positionMatingUnitForest()`** (the function whose internals this
design replaces):
```
R/makePedigreeDiagramData.R:804    (recursive per-component self-call)
R/makePedigreeDiagramData.R:1682   (from makePedigreeMatingLayout())
```
Both preserved unchanged — this design does not change the function's signature or its
`data.frame(id, x, gen)` return contract (§Impact Analysis).

**Test files exercising `.positionMatingUnitForest()` directly** (`pos <-
.positionMatingUnitForest(...)` call sites, `grep -rn`):
```
tests/testthat/test_positionMatingUnitForest.R    (3,494 lines — ~70 pos <- ... call sites)
tests/testthat/test_resolveEdgeNodeCollisions.R   (618 lines — 2 call sites)
tests/testthat/test_addRectilinearWaypoints.R     (861 lines — 1 call site)
tests/testthat/test_makePedigreeMatingLayout.R    (1,662 lines — 2 call sites)
```
6,635 lines total. This bounds Migration Path Phase 3's re-derivation scope, not the design.

**`quadprog`/`solve.QP` references** (confirming a genuinely new dependency, not already
half-present): `grep -rn "quadprog\|solve\.QP" R/ NAMESPACE DESCRIPTION` → **0 matches**. Confirmed
again this session (S670 found the same). `DESCRIPTION`'s current `Imports:` (18 packages) does not
include `quadprog`; `kinship2` itself is `Suggests`-only (`DESCRIPTION`, `Suggests:` block) and
never a runtime dependency of this package today.

**Collision-avoidance code being replaced** (§Context "Current state" table, right column
"Replaced"), located by function/comment-block search, not memory:
```
R/makePedigreeDiagramData.R:1132-1206   .deCollideIndividualPoints() definition
R/makePedigreeDiagramData.R:1224-1227   its call site (B1 de-collision)
R/makePedigreeDiagramData.R:1294-1338   B1-vs-unrelated-individual proximity pass (S661/S662)
R/makePedigreeDiagramData.R:1340-1427   Track 7 Phase 2 union sweep (S648/S649)
R/makePedigreeDiagramData.R:1429-1515   duplicate de-collision + Track 7 Phase 4 (S654/S658)
```
Associated constants being repurposed (kept, same values, new role — §Decision 3):
`.kMaxIndividualPush` (:781), `.kMaxUnionPush` (:1280), `.kMaxB1ProximityPush` (:1292),
`unionClearanceIndividual`/`unionClearanceUnion`/`individualClearance` (:1262–1270).

**Reserved node-id prefixes** (must not collide with any new QP-internal identifier):
`^__union_|^__dup_|^__drop_|^__bar_|^__proj_` (`.buildMatingUnitForest()`, :401). This design
introduces no new node kind and no new id prefix — `.solveJointQP()` operates entirely on
`.positionMatingUnitForest()`'s existing node population (§Decision 2).

---

## Migration Path

Each phase is a separate implementation session (S670 §4's own Effort-L / 2–4-session estimate),
full RED/GREEN/REFACTOR per `CLAUDE.md`'s TDD contract. **Do not bundle phases** — FM #18/#19.

### Phase 1 — `.solveJointQP()` standalone, not yet wired into production

**What DONE looks like:** a new internal function `.solveJointQP(provisionalPos, matingUnits,
duplicates, childEdges)` implementing Decisions 2–4 in full, with its own dedicated test file. NOT
yet called from `.positionMatingUnitForest()` — verified standalone, against the same small
fixtures S670's own probe used (Track B full/shrunk, Track C, D1–D3 — none of which have census
findings, so this phase's job is confirming the QP reproduces feasibility/order, not fixing a
defect). `quadprog` promoted from absent to `Imports:` in `DESCRIPTION`, `renv::snapshot(dev =
TRUE)` re-run (per `CLAUDE.md`'s Build/Test/Verify section).
**Verification commands:** `devtools::test(filter = "solveJointQP")`; `Rscript -e
'quadprog::solve.QP'` resolves (dependency wired); the RED phase's own sweep of `wUnion`/`wDup`
(Decision 4) reported in the session's own test/handoff, closing the "not assumed here" caveat.
**Session boundary:** close out here. Phase 2 is a separate session.

### Phase 2 — Cutover on small fixtures only

**What DONE looks like:** `.positionMatingUnitForest()`'s five collision-avoidance passes
(§Evidence-Based Inventory list) replaced by a call to `.solveJointQP()`, exercised on Track B
full/shrunk, Track C, D1–D3 only — **not** the real 375 fixture yet. `test_positionMatingUnitForest.R`'s
small-fixture assertions re-derived against the new engine's actual output (not assumed compatible
with the old formulas — matching the S666 precedent's own documented gotcha).
**Verification commands:** `Rscript data-raw/pedigreeDrawingErrorCensus.R` re-run — Track B/Track
C/D1–D3 rows must stay at 0 on every class they were already 0 on (no regression), AND Track C's
own Finding #1/#2/#7 carrying rows (5 (a), 3 (b), 1 (d)) must now read 0 for (a)/(b) — the exact
classes this design structurally guarantees.
**Session boundary:** close out here. Phase 3 is a separate session.

### Phase 3 — Real-375-fixture cutover + full pinned-suite re-derivation

**What DONE looks like:** the real fixture routed through the new engine; the bulk of the 6,635
lines identified in §Evidence-Based Inventory re-derived (not assumed); committed reference images
(`trackB-nprc-full.png`, `trackC-nprc-rectilinear.png`, the real-fixture render) regenerated and
**owner-reviewed** before close-out — matching the S666/S667 precedent of an explicit visual
approval, not just a passing test suite, before a pedigree-drawing engine change ships.
**Verification commands:** `Rscript data-raw/pedigreeDrawingErrorCensus.R` on the real fixture —
classes (a)/(b)/(c1) must read 0 (structurally guaranteed by Decision 3's constraints); class (e)
should be unchanged at 56 (Decision 5: row policy untouched); class (f) unchanged at 0 (Decision
6: `.packComponents()` untouched); class (c2)/curved-chord counts reported, not assumed 0 (the QP
does not touch the jog/dogleg rendering layer — §Impact Analysis); full clean regression (per
`CLAUDE.md`'s Build/Test/Verify) 0 failed/0 error attributable; `lintr::lint_package()` 0 findings.
**Session boundary:** close out here. Phase 4 is a separate session (may be skipped/folded into
Phase 3's own close-out if that session's scope allows — not pre-committed here).

**Phase 3 record (Session 675, 2026-09-03):** DONE with one amendment (Decision 3, above) and two
findings the verification line above did not anticipate. (1) **Class (b) is not reachable by the
constraints** — Learning 723's point, now measured at real-fixture scale: 46 of 237 unions stay
off their mate midpoint under every floor setting because the QP honours Phase A's provisional
*order* (Decision 1). S675 separated the 45 same-row cases: 8 polygamous anchors (structural —
one anchor node can flank only two unions), 11 two-union anchors whose Tier 2/3 provisional
values put both unions on the same side, and the rest units whose genuine (non-B1) mate sits far
away under her own parents. (2) **Order-driven crossing growth**: same-row colliding edges before
jog repair 88 → 266 (obstacle pairs 1,751 → 2,549; jog repairs 89 → 267), and D1 sibship bars
sharing an inter-row y now overlap in x for 312 pairs (was 0) — both because the union dot is now
centred between its parents (Decision 4 term 3) rather than sitting on its children's mean, so
drop points and mate lines span other nodes. All same-row crossings are still resolved by the
unchanged repair pass (class (c1) after repair = 0); class (c2) 414 → 587. Both findings trace to
the *provisional order* Phase A hands the QP, not to the QP itself — the natural follow-up is a
design session on provisional ordering (kinship2's `alignped1–3` order heuristics and/or spouse
duplication), recorded in `BACKLOG.md`. Verification actually run: full clean regression 0
failed/0 error attributable, `lintr` 0 findings, live `shinytest2` E2E Diagram-tab suite, census
re-run (Real 375: a 0, b 47, c1 post 0, c2 587, d 0, e 56, f 0), images regenerated and
owner-reviewed (see the S675 handoff for the review outcome).

### Phase 4 — Cleanup

**What DONE looks like:** the now-fully-dead collision-avoidance code and constants
(§Evidence-Based Inventory list) deleted (verified dead first — `git log -1 --oneline -- <file>`
before `rm`, per `SAFEGUARDS.md` Blast Radius Limits); `NEWS.Rmd` dev-version entry added (plain-
language, per `CLAUDE.md`'s S628 criterion); doc-comments referencing the deleted tiers/passes
updated; `BACKLOG.md` Up Next item 1 marked DONE and its GitHub issue (if one is filed for the
implementation, per `CLAUDE.md`'s close-out checklist) closed.
**Verification commands:** `grep -rn "deCollideIndividualPoints\|kMaxUnionPush\|kMaxB1ProximityPush"
R/` returns nothing; full clean regression + lint, same bar as Phase 3.
**Session boundary:** close out here.

---

## Impact Analysis

### What changes

- Every union/B1/duplicate node's final `x` (computed by the QP, not the old formulas +
  capped-push passes).
- Potentially every genuine individual's final `x` too — the QP re-solves everyone in a component
  simultaneously (kinship2 does the same); Phase A's `tier1X` becomes a provisional/ordering input,
  not the final answer, for every node in the component, not only union/B1/duplicate ones.
- The `.deCollideIndividualPoints()`/Track 7 Phase 2/Phase 4 code and its `.kMax*` constants
  (deleted in Phase 4, once confirmed dead).
- `test_positionMatingUnitForest.R`'s ~70 pinned numeric assertions (re-derived, not assumed —
  Phases 2/3).

### What does NOT change (explicit scope boundary)

- `.positionMatingUnitForest()`'s own signature and return contract: `(ped, forest) ->
  data.frame(id, x, gen)`. `makePedigreeMatingLayout()`'s own public signature/contract.
- `.buildMatingUnitForest()` (D1/D2), `.forestComponents()`/`.packComponents()` (Decision 6),
  `.addRectilinearWaypoints()` (D1 sibship bars, D2 doglegs — Decision 5), `.resolveEdgeNodeCollisions()`
  (jog repair — still needed, §below).
- Row assignment (`gen`, Decision 5) — every node renders on the same row it does today.
- Census Finding #3 (jog offset must exceed the 25 px symbol radius) — independent of this design,
  named explicitly out of scope by S671's own handoff; a separate, bounded future fix.
- The stale `test_resolveEdgeNodeCollisions.R:20-29` "D2 unreachable" comment (`BACKLOG.md`
  Housekeeping) — independent, not touched here.

### What might break (risk assessment)

- **Provisional-order bugs become visible ordering bugs, not just position-magnitude bugs.** Today,
  a subtle bug in `qualifies()`/S666's shift/`.forestComponents()` mostly changes *how far apart*
  things land. Post-QP, the SAME bug changes provisional rank, which the QP then treats as a *fixed
  constraint* — two individuals could render in the wrong left-right order entirely. Phase 2/3's
  visual review (not just numeric test pass) is the explicit countermeasure.
- **QP infeasibility.** The constraint set as designed (Decision 3) is a per-row linear chain, which
  is always feasible by construction (no upper bound, so any sufficiently large spread satisfies
  every inequality) — `quadprog::solve.QP()` should never report infeasibility for this shape.
  Phase 1's RED tests should include an explicit assertion that `solve.QP()` does not error, as a
  regression guard against a future constraint-construction bug that could break this invariant.
- **Orphan mating units (issue #154, both parents dangling — `anchorOf` is `NA`).** These units get
  a QP variable and adjacency constraints (like every other node) but no anchor/non-anchor pair, so
  Decision 4's spousal-pull, child-centering, and union-centering terms (1–3) do not apply to them —
  their children get no centering pull at all under this design, an edge case kinship2 sidesteps
  entirely (`fixParents()` synthesizes a founder before its own QP ever runs) and this project has
  no equivalent pre-processing for. `test_positionMatingUnitForest.R` already has dedicated
  orphan-unit test cases (e.g. `:751`, "sire AND dam both dangling") — Phase 1/2's RED tests must
  explicitly characterize this case, not assume it falls out of the general formulas.
- **`.resolveEdgeNodeCollisions()`'s job shrinks but does not disappear.** It jogs a same-row edge
  (typically a sibship bar or a mate line spanning several intermediate nodes) that crosses an
  unrelated symbol *between* its two endpoints — Decision 3's constraints only guarantee **adjacent**
  pairs clear each other, not that a long bar spanning 5 columns doesn't cross the 3rd one. Expected
  to fire less often post-QP (many of today's crossings originate from a too-close neighbor the jog
  was routing around — Finding #3's own text), but is not eliminated and stays unchanged code.
- **Performance at scale is not measured, only estimated** (§Rationale) — Phase 1's RED run is the
  first real measurement; if the real fixture's actual variable/constraint count differs materially
  from the ~714/~700 estimate, that surfaces immediately and cheaply, before any production cutover.

---

## Verification Plan

- **Phase-local:** each Migration Path phase's own verification commands (above) — the acceptance
  gate is `data-raw/pedigreeDrawingErrorCensus.R`'s six-class scoreboard, per the census's own
  Recommendation 2 ("adopt it as the acceptance gate for every further layout change... measured by
  c2, not c1, for edges").
- **Cross-check against kinship2 where structurally comparable:** Phase 1's standalone tests should
  confirm the QP achieves the same `>= minSepFor(...)` floor kinship2 achieves `>= 1` on (S670 §2.2)
  — i.e., the constraint is never violated, at any tested weight setting, extending Learning 678's
  established sweep methodology to this project's own two new terms (Decision 4, "Weight defaults").
- **Owner visual review before Phase 3 close-out** — not optional, matching the S666/S667
  precedent: a passing numeric test suite is necessary but not sufficient for a pedigree-drawing
  engine change (`SAFEGUARDS.md`'s render-dependency-completeness principle, applied here to a
  positioning engine rather than a font/CSL asset).
- **Full clean regression + lint** at every phase boundary (`CLAUDE.md` Build/Test/Verify section),
  not only at the end.

---

## Open Questions for a Future Session

1. **Exact `wUnion`/`wDup` defaults** — Decision 4 gives starting values ported from kinship2 or
   chosen by analogy; Phase 1's own empirical sweep (mirroring Learning 678's methodology) is the
   actual source of truth, not this document.
2. **Whether to fold `.packComponents()` into the joint QP later** (Alternative 2, rejected for this
   round on risk/scope grounds, not on any structural defect) — worth revisiting only if a future
   session finds a concrete case `.packComponents()`'s rigid shift handles incorrectly; no such case
   is known today.
3. **Whether Finding #3 (jog offset) should be fixed before or after this design ships** — named
   independent by S671; no ordering dependency either way, purely a scheduling choice for whoever
   picks up the standing pedigree-fidelity priority next.
