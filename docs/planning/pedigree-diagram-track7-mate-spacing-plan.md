# Pedigree Diagram Track 7: mate spacing and union centering for qualifying pairs

**Status:** DESIGN, session S646 (2026-08-27). **RATIFIED, session S646** (§10) -- Option A adopted
as scoped, no changes. **Phase 1 implementation DONE for individuals, session S647 (2026-08-27)**
-- §2's core formulas shipped (widen + recenter, `qualifies()`-gated), plus a capped
collision-avoidance fix for individual-shaped points (§11). §11's own 4th finding (union-dot
proximity to unrelated individuals) and 5th finding (union/children decoupling) were disclosed,
not fixed. **Phase 2 DESIGN, session S648 (2026-08-27)** -- §12: Pre-RED measurement (confirms
Phase 1 itself introduced 19 of 20 union-dot near-misses on the real fixture, up from 1
pre-Track-7) + a capped, radius-proportionate push design for the union side only, independently
verified by a 3-agent adversarial workflow (§12.8). **Implementation is a separate future
session** -- see `BACKLOG.md`.

**Origin:** `BACKLOG.md` "Up Next" (filed S645, 2026-08-27, post-close-out, owner-directed --
"place [this] as the next action item"), itself found via direct owner visual review of the
corrected Track B full-fixture image pair in `vignettes/articles/kinship2-fidelity-validation.qmd`.
S645's own root-cause note is the starting point for this document, re-verified directly against
source this session (not re-stated from memory).

**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (chosen over
`DESIGN_WORKSTREAM.md`, matching this project's own established precedent for pedigree-diagram
positioning-algorithm decisions -- Track 6's own plan header cites S432's issue #129 plan, S458's
Option 2 layout plan, S464's rectilinear-waypoint plan, S471/S473's issue #143/#144 plans, and
S572's Track 4 plan, all making the same call for the same reason: this is a technical/
algorithm-correctness decision, not a panel/visual-arrangement one).

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

- The Walker/BJL apportioning engine (`R/positionTreeApportion.R`, issue #141/S592-S621) and its
  pedigree-specific adapter, `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R:627-851`),
  are ratified and shipped. This document does not propose replacing the recursive tree-apportion
  engine, only reconsidering two of its downstream formulas (Tier 2's union-`x` derivation, Tier
  3's non-anchor mate offset) for one specific, already-gated subset of mating units.
- Track 6 (S576/S578, `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md`)
  ratified that a mating unit's `x` is derived from its own children, not its two parents --
  explicitly reversing the OLD algorithm's own "midpoint of two parents" formula because, for a
  **polygamous anchor** (one who anchors 2+ mating units), the anchor's own `x` is a cross-union
  centroid pulled away from any one union's own children, producing long, illegible sibship-bar
  edges. (Precision note, found by this session's own adversarial verification: Track 6's own
  ratified formula was the midpoint of only the two *extreme* children,
  `(min(kidX) + max(kidX)) / 2` -- today's shipped code, from the later Walker/BJL migration,
  instead computes `unitX[[u]] <- mean(tier1X[kids])` (`R/makePedigreeDiagramData.R:757-760`), an
  arithmetic mean over *every* child. The two are identical for exactly 2 children and diverge for
  3+; neither cited planning document specifies the mean formula that actually ships today. This
  divergence pre-dates this document and is not this document's own scope to resolve -- noted for
  accuracy, not treated as a defect here.) **This document's own recommendation (§2) does not
  reopen or regress Track 6's fix** -- see §2.4/§3 for why the qualifying subset this document touches is provably immune to
  the cross-union-centroid problem.
- Track 5 established, as a structural invariant (proof-by-construction, not merely empirical),
  that every child edge (D1) and every mate edge (D2) is orthogonal regardless of the union's `x`
  value -- D1's sibship-bar waypoint loop (`R/makePedigreeDiagramData.R:1440-1487`) runs
  unconditionally, with no `gen`/`x` check of any kind, and D2's dogleg (`:1489-`) fires purely on
  a `gen`-inequality gate (`if (identical(side$gen, Ugen)) next`, `:1526`), never on `x`.
  **Correction (found by this session's own post-draft adversarial verification, §9): an earlier
  draft of this document cited `:1533-1535, 1561-1563` for this invariant, copied verbatim from
  Track 6's own plan without re-verifying against current source -- neither range actually
  supports the claim (1533-1535 is D2's edge-dataframe construction, downstream of the real gate;
  1561-1563 is an unrelated edge-color comment for issue #137/D10). The invariant itself is still
  true, re-confirmed directly at the corrected citations above; only the earlier citation was
  wrong.** **This document's change cannot regress Track 5's invariant**: neither D1 nor D2 reads
  anything about `x` beyond its numeric value, so widening a subset of `x` values changes edge
  geometry, never edge orthogonality.
- Track 3's own parent-span clamp is gone by construction (`R/makePedigreeDiagramData.R:610-615`),
  and the Walker/BJL redesign plan explicitly warns that "clamping a correctly child-centered
  position back toward an unrelated co-parent's position elsewhere re-introduces the 'clamp toward
  a parent' instinct Track 6 was built to move away from"
  (`docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md:161`). **This document
  does not clamp any union toward an *unrelated* co-parent** -- see §2.4 for why the qualifying
  gate structurally excludes exactly the case that warning describes.
- Learning 641 (`PROJECT_LEARNINGS.md`, S615) already measured and reported, as a pre-existing,
  deliberately-deferred characteristic, that this project's shared `1e-3`-raw-unit "exact-tie"
  epsilon nudge (used throughout Tier 2/Tier 3's tie-break sweeps) produces only a 0.12px
  separation at this project's own `xScale = 120` (`R/makePedigreeDiagramData.R:1047`) -- below
  vis.js's own 1px coordinate-rounding granularity -- and explicitly deferred any fix to "a future,
  dedicated design session." **This document is that session, for the one specific instance of the
  pattern the owner flagged (the mating-unit dot sitting on its anchor)** -- it does not attempt to
  fix the general epsilon-nudge pattern everywhere else in the codebase (§8).

### 1.2 What this document decides

The 3 questions `BACKLOG.md`'s own filing named, re-scoped slightly by this session's research
(§1.4) into 2 decision points plus one already-resolved question:

1. **What should a qualifying mating unit's final `x` be derived from** -- its own children (today,
   unconditionally) or the true midpoint of its two parents' own `x` (for a well-defined "qualifying"
   subset only)? (§2.1)
2. **How much should the non-anchor mate's derived offset from the anchor widen**, and toward what
   target? (§2.2)
3. *(Resolved by construction, not a separate open question --* §2.4 *): how does this interact
   with Tier 1's BJL apportioning, the existing de-collision/sweep passes, and Track 5's D1/D2
   invariants?* Answer: by restricting the entire change to the pre-existing `qualifies()` gate
   (`R/makePedigreeDiagramData.R:777-791`), this document introduces no new invariant and no new
   risk surface beyond what already ships today for that subset -- it widens values already
   computed inside an already-safe boundary, rather than drawing a new one.

### 1.3 Full history: how the current defect arose

Read directly from `.positionMatingUnitForest()` this session (`R/makePedigreeDiagramData.R:745-801`,
current `HEAD`, re-verified against source, not carried forward from S645's own note):

- **Tier 2** derives every mating unit's `x` as the mean of its own children's final Tier-1 `x`
  (`:757-760`). For an anchor with exactly one mating unit, Tier 1's own BJL apportioning
  independently centers the anchor's `x` over that *same* child span (`R/positionTreeApportion.R:
  212-223`, "Aesthetic 4, 'parent centered over children,' by construction" -- the anchor's own
  `prelim` is set to `(firstKid$prelim + lastKid$prelim) / 2L`, the midpoint of its first and last
  child). The two formulas are centering over the *same set of children* by two different routes,
  so the union's `x` and the anchor's `x` land within a de-collision epsilon of each other --
  confirmed empirically this session (§1.4) and independently confirmed by Learning 641's own,
  unrelated investigation (S615): the epsilon separation (`1e-3` raw units, `0.12`px at
  `xScale = 120`) is below vis.js's 1px rounding, so the union dot renders pixel-coincident with
  its anchor.
- **Tier 3**'s `derivedX()` (`:792-801`) places the non-anchor mate at
  `unname(tier1X[[p]]) + sign * minSep * 0.4` (`p` being the anchor) -- i.e. `0.4` raw units
  (`minSep <- 1L`, `:643`) from the **anchor's own `x`**, never from a genuine center. At this
  project's `xScale = 120`, that is a
  48px center-to-center offset -- on the same order as the node's own rendered footprint
  (`size = 25L`, `:1127`/`:1145`), so the two symbols sit immediately adjacent, not visibly spread
  apart.
- **`derivedX()`'s Tier-3 treatment is already gated** by `qualifies()` (`:777-791`): it only
  applies its "B1" formula (offset directly from the anchor) when the unit's anchor has **exactly
  one** mate (`mateCountP == 1`), the mate has **exactly one** anchor-side union (`mateCountM ==
  1`), the anchor has no direct child of their own, and the pair's sex codes are unambiguously
  opposite. Every other case (a polygamous anchor, a mate who has their own direct child or their
  own other union, an ambiguous-sex pair) falls to the "B3" branch (`unname(unitX[[unitId]]) +
  minSep * 0.4` -- offset from the **union**, not the anchor) or gets no Tier-3 point at all (B2). This gate
  is the pre-existing structural boundary this document's own recommendation reuses (§2.4).

### 1.4 Fresh evidence gathered this session (not assumed carried forward)

Measured directly against 2 fixtures via `pkgload::load_all()` + `.buildMatingUnitForest()` +
`.positionMatingUnitForest()`, called live, not read from a script's prior output:

- **Track B full fixture** (`tests/testthat/test_comparePedigreeStructure.R`'s
  `.pedTrackBFixture()`, 16 individuals, 4 mating units): all 4 anchored units qualify
  (`qualifies() == TRUE` for all 4), none polygamous -- matching `BACKLOG.md`'s own citation that
  P1x P2, P3xP4, C4xP6, M1xG3 all show the identical near-zero-separation pattern. **Every mating
  unit the owner actually observed and flagged is inside the qualifying subset this document
  addresses.**
- **The real, bundled 375-individual fixture**
  (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`, 237 mating units, matching Track 6's own
  citation exactly): **60 of 237 anchored units (25.3%) qualify**; 177 (74.7%) do not. Of 209
  unique anchors, 22 (10.5%) are polygamous (anchor 2+ unions). **This is the honest scope
  boundary of this document's recommendation: it visibly improves roughly 1 in 4 mating units on
  real colony data, not all of them** -- the remaining 3 in 4 (polygamous anchors, anchors/mates
  with their own other relationships, ambiguous-sex pairs, dangling co-parents) are unaffected by
  this document and remain a separate, deferred, higher-risk question (§8).
- **kinship2's own reference algorithm, read directly from the installed package's source this
  session** (`kinship2:::alignped1`, `kinship2:::alignped3`, `kinship2:::alignped4`, R 4.6 /
  kinship2 1.9.6.2 as installed in this project's `renv` library, cross-checked against kinship2's
  own bundled vignette `doc/align_code_details.Rmd`) -- **not assumed from prior articles or
  descriptions, and independently re-verified twice** (once by this session's own adversarial
  verification workflow, §9, and once more directly by this session afterward, by running
  `kinship2::align.pedigree()` on a hand-built trio while sweeping `align[2]` over 6 orders of
  magnitude):
  - `alignped1()` places spouses as **adjacent integer-spaced siblings** in its own "packed"
    pre-layout (`pos[lev, ] <- 0:nspouse`) -- a full `1`-unit initial spacing per spouse.
  - `alignped4()` (kinship2's own final-position solver, run whenever `align = TRUE`, the default)
    is a genuine **constrained quadratic program** (`quadprog::solve.QP`) with a **hard per-row
    constraint that adjacent individuals never sit closer than `1` raw unit apart** -- confirmed
    exactly, both in the `cmat`/`dvec` constraint construction and in the vignette's own prose
    ("each subsequent one must be at least 1 unit to the right").
  - **Correction (an earlier draft of this document got this wrong -- found by this session's own
    adversarial verification, §9, then independently re-confirmed directly, not merely trusted):**
    the spousal term in `alignped4()`'s penalty matrix is `align[2] * (x1 - x2)^2` -- per kinship2's
    own vignette, this "tends to keep them together," with `align[2]` (default `2`) only
    controlling *the relative importance* of spouse-closeness vs. parent/child-centering, not a
    target separation distance. Its unconstrained minimum is **zero** separation; the *only* reason
    spouses end up apart at all is the same hard `>= 1` per-row floor every adjacent pair gets.
    Confirmed empirically (both by the verification workflow, across kinship2's own real bundled
    41-person sample pedigree and 3 synthetic ones, and independently re-confirmed directly this
    session on a hand-built trio): sweeping `align[2]` from `0.001` to `1000` never changed the
    achieved spousal separation away from exactly `1.0` raw unit. **kinship2's real, rendered
    spousal gap equals the ordinary adjacency-floor gap -- `1.0` raw unit, never `1.414`, and never
    wider than one standard sibling-gap unit.** (The originally-drafted `sqrt(align[2]) ~= 1.414`
    figure was a real number computed from a real default, but it is a *penalty weight*, not an
    achieved distance -- reading it as a target distance was the error.)
  - **Corrected implication for this document's target:** kinship2 does not achieve mate-spacing
    via a small local offset; it solves for **all** positions jointly, and its real spousal gap is
    the *same* `1` raw unit any two ordinary adjacent individuals get -- no wider. The honest
    kinship2-comparable target for nprcgenekeepr's own anchor-to-mate separation is therefore **`1`
    raw unit (`minSep`, `R/makePedigreeDiagramData.R:643`)**, not a larger multiple: nprcgenekeepr's
    current `0.4`-raw-unit offset is under half of that; matching it means the offset should equal
    `minSep` itself, i.e. the same minimum gap this project's own algorithm already guarantees
    between any two unrelated individuals in a row -- not an arbitrary wider constant.
- **A preliminary collision-headroom probe** (this session, against the real 375-individual
  fixture): recomputing each of the 60 qualifying pairs' mate offset at candidate values
  (`0.4`/`0.6`/`0.75`/`1.0`/`1.2`/`1.4` raw units, anchor held fixed) and measuring the resulting
  distance to the nearest *other* node (any node besides that pair's own anchor/mate/union) in the
  same displayed generation row found **near-zero headroom to some unrelated node already at the
  currently-shipped `0.4` multiplier**, not only at wider candidates -- i.e., collision risk against
  a third, unrelated node is not obviously a *new* risk widening introduces; some version of it may
  already be latent in the shipped algorithm on this densely-populated real fixture. **This finding
  is preliminary and not root-caused** (it was not traced to a specific colliding node/formula this
  session) -- it is reported here as a real signal the implementing session must investigate with a
  live render (matching Learning 641's own methodology: raw-unit arithmetic is not evidence of
  visual non-overlap), not treated as either a green light or a blocker on its own. This probe
  already covered `delta = 1.0` (the corrected target above), so no new probe is needed on that
  account -- the collision question stands exactly as previously measured.

---

## 2. Decision

### 2.1 Recompute a qualifying unit's `x` as the true midpoint of its two parents, not its children

For units where `qualifies(unitId)` is `TRUE` (the existing gate, `R/makePedigreeDiagramData.R:
777-791`, unchanged): once the non-anchor mate's widened offset (§2.2) is computed, set the
union's own final `x` to the midpoint of the anchor's `x` (unchanged, from Tier 1) and the mate's
newly-widened `x` -- i.e. `(tier1X[[anchor]] + newMateX) / 2`, replacing Tier 2's
`mean(tier1X[kids])` **for this subset only**. Every unit where `qualifies()` is `FALSE` keeps
Tier 2's existing child-centered formula completely unchanged.

This is the lowest-blast-radius way to satisfy the owner's own framing ("kinship2... spreads mated
pairs apart with the descent line centered between them") for exactly the pairs kinship2 itself
would also treat as simple, uncomplicated unions -- while leaving Track 6's own regression-tested
child-centered formula untouched for every unit it was built to protect (polygamous anchors,
cross-relationship pairs).

### 2.2 Widen the non-anchor mate's Tier-3 offset to match `minSep` -- kinship2's own real target

Change `derivedX()`'s B1 branch (`R/makePedigreeDiagramData.R:792-797`) from `minSep * 0.4` to
**`minSep`** itself (currently `1L` raw unit, `120`px at this project's `xScale = 120`) -- i.e.
drop the `* 0.4` multiplier. This is doubly justified, not guessed: (1) it is this project's own
existing minimum-separation convention, already used to guarantee adjacent unrelated individuals
never sit closer than `minSep` apart (Tier 1's own sweep, `:733-743`); (2) it is kinship2's own
real, directly-measured achieved spousal separation (§1.4's corrected finding) -- kinship2 never
places spouses farther apart than its own per-row adjacency floor of `1` raw unit, so matching
`minSep` exactly *is* matching kinship2, not an arbitrary wider constant. The B3 branch (offset
from the union, for non-qualifying members) is explicitly **unchanged** -- widening is scoped to
the qualifying B1 case only, matching §2.1's own scope.

**Why this document commits to a specific value here, unlike an earlier draft's hedged range:**
the earlier draft (before this session's own adversarial verification, §9) proposed an unpinned
`0.75`-`1.4` range "informed by" a kinship2 figure that verification found to be wrong (§1.4). Once
corrected, the honest kinship2-comparable reference point is a single, specific, already-existing
constant (`minSep`) rather than a range around a mistaken number -- there is nothing left to hedge
about the *target*. What genuinely still needs the implementing session's own Pre-RED empirical
validation (matching Track 6's own "measured directly, not assumed" practice) is **not** the target
value, but the **collision-headroom question** §1.4's preliminary probe raised: whether `minSep` (or
any candidate value) leaves adequate visual clearance from unrelated nodes, verified via a live
render (per Learning 641's own methodology), not raw-unit arithmetic alone.

### 2.3 No change to `dupX`, the final de-collision pass, or any B2/B3 logic

Duplicate-node `x` derivation (`R/makePedigreeDiagramData.R:819-826`, the B3-analog for duplicate
nodes) and the final exact-tie de-collision sweep (`:827-838`) are untouched -- they already
correctly handle whatever `x` values Tier 2/Tier 3 hand them, regardless of the specific formula
(the same "these passes are generic over `x`, not formula-specific" property Track 6's own §2.2/2.3
established for its own change).

### 2.4 Why this is safe against Track 6's own regression and Track 3's own removed-clamp warning

Both prior warnings (§1.1) describe a **cross-relationship** hazard: an anchor's own `x` being
pulled toward a position derived from a relationship *other than* the one union being positioned
(a second marriage's children, an unrelated co-parent elsewhere in the forest). `qualifies()`
structurally cannot admit that hazard for the units it selects:

- `mateCountP == 1` -- the anchor has **no second union** to be pulled toward. There is no
  "elsewhere" for the anchor's own `x` to be a centroid *of*, so recentering the union between this
  anchor and this mate cannot decouple it from some *other* set of children the way a polygamous
  anchor's cross-union centroid would.
- `mateCountM == 1` and `!hasOwnDirectChild(anchor)` -- the mate has no other union either, and the
  anchor has no direct child of their own (a D5 case) competing for centering influence.
- Therefore, for exactly this subset, "the anchor's `x`" and "the anchor's position within *this
  specific* union's own subtree" are the same thing, by construction -- there is nothing to clamp
  toward that is unrelated. This is the precise condition Track 3's removal warning
  (§1.1, "clamping ... back toward an *unrelated* co-parent's position") does not describe, and the
  precise condition Track 6's own polygamous-anchor regression (§1.1) cannot arise under.

This argument is proof-by-construction (matching Track 5's own "confirmed by reading the code
directly, not re-measured empirically" standard for its own invariant, §1.1) -- it does not require
re-deriving Track 6's original 375-individual-fixture measurement, because this document changes
`x` for a set of units *disjoint* from the set Track 6's own fix protects (a unit either qualifies,
in which case it was never at risk of the cross-union-centroid problem in the first place, or it
doesn't, in which case this document leaves it untouched).

---

## 3. Rationale

The owner's own framing (kinship2 "spreads mated pairs apart... centered between them") is, per
§1.4's corrected direct source read, true of kinship2's own algorithm in the *structural* sense
that matters here -- kinship2 always places spouses as genuinely separate, adjacent positions (a
full `1`-raw-unit gap, never coincident) with the descent line centered at their true midpoint --
though **not** in the magnitude sense an earlier draft of this document mistakenly claimed: that
gap is exactly the *ordinary* adjacency floor, not an unusually wide one. What the owner observed
as "spread apart" in kinship2's own renders is the *presence* of a real, structural separation at
all -- exactly what nprcgenekeepr's current `0.4`-raw-unit offset (well under that floor) and
near-coincident union dot both lack, not a magnitude nprcgenekeepr needs to exceed. kinship2
achieves even this modest, standard-floor separation via a **global, jointly-solved constrained
optimization** over every individual's position at once, a fundamentally different architecture
from nprcgenekeepr's **local, recursive, tree-structured** BJL apportioning. Porting kinship2's
actual mechanism (a quadratic program) is out of proportion to a cosmetic spacing complaint and
would reopen the very
migration this project already completed carefully and at real cost (issue #141, Tracks 1-6,
S592-S621) -- see Alternatives (§4), Option C.

The chosen approach instead reuses machinery this project already has and already trusts: the
`qualifies()` gate already exists, already draws exactly the boundary this document's own safety
argument (§2.4) needs, and already governs a Tier-3 "special case" mechanism structurally
compatible with genuinely centering a union between two parents. Widening within that boundary is
additive and reversible -- it changes numbers computed for a known-safe subset, not the algorithm's
own architecture or its safety invariants.

---

## 4. Alternatives Considered

| Alternative | Pros | Cons | Why Rejected / Deferred |
|---|---|---|---|
| **A. RECOMMENDED -- widen + recenter, `qualifies()`-gated only (§2)** | Low blast radius; reuses an existing, already-proven-safe boundary; proof-by-construction safety argument; directly fixes every pair the owner actually observed (Track B's own 4 pairs all qualify); target constant (`minSep`) is well-justified, not guessed (§2.2) | Only visibly improves ~25% of mating units on real colony data (§1.4); collision headroom against unrelated nodes still needs live empirical validation before shipping (§7) | -- (this is the recommendation) |
| **B. Generalize to every anchored unit (drop the `qualifies()` gate)** | Would visibly improve all 237 units, not just 60 | Reintroduces exactly the polygamous-anchor cross-union-centroid regression Track 6 was built to fix, and exactly the "clamp toward an unrelated co-parent" hazard the Walker/BJL plan explicitly warned against (§1.1); needs its own dedicated measurement session in Track 6's own style before it could be judged safe | **Deferred** -- filed as a separate, future BACKLOG item (§8), not attempted in this document |
| **C. Port kinship2's own quadratic-program layout** | Would match kinship2's actual mechanism, not just its visual target | A full architectural paradigm shift away from the Walker/BJL engine this project only just finished migrating to (issue #141), at high cost, for a purely cosmetic spacing improvement; risks needing to re-verify Track 5's D1/D2 invariants under a wholly different positioning mechanism, unanalyzed here | **Rejected** -- disproportionate to the problem |
| **D. Rendering-only visual offset (leave `x` unchanged; nudge only the drawn pixel position)** | Zero risk to any positioning invariant or edge geometry | Decouples the visually-displayed symbol location from the `x` value edges/tooltips actually reference -- introduces a new class of defect (edges pointing at a position that doesn't match what's drawn), violating the "fixed-coordinate rendering mechanism stays coupled to genuine data positions" property Track 6's own plan relied on (§1.1) | **Rejected** -- trades a real, fixable data-level gap for a worse, structurally-decoupled rendering gap |

---

## 5. Impact Analysis

| System / surface | Impact | Action Required |
|---|---|---|
| `.positionMatingUnitForest()` Tier 2 (`:757-760`) | Adds a `qualifies()`-gated branch recomputing `unitX` for the qualifying subset only | Implementing session's own RED/GREEN |
| `.positionMatingUnitForest()` Tier 3 `derivedX()` (`:792-801`) | B1 branch's multiplier drops from `minSep * 0.4` to `minSep` (§2.2) | Implementing session's own live-render collision-headroom check (§7) before shipping |
| Non-qualifying units (~75% on real colony data) | **No change** -- Tier 2/Tier 3's existing formulas are untouched for this majority | None |
| Track 5 D1/D2 edge orthogonality | **No change** -- proof-by-construction (§1.1); D1/D2 read `x` generically | Re-confirm at implementation via the existing D1/D2 test suite, not a new analysis |
| `test_positionMatingUnitForest.R` / `test_positionMatingUnitForestBJL.R` | New assertions needed for the qualifying-subset formula; existing non-qualifying-case assertions should be unaffected | Implementing session |
| `kinship2-fidelity-validation.qmd` (Track B images) | Track B's 4 mating units all qualify (§1.4) -- expect all 4 union dots to visibly separate from their anchors after implementation | Regenerate + visually re-verify, matching this project's own "verify diagrams against ground truth" standard |
| Real-colony rendering (large pedigrees) | Only ~25% of mating units visibly change; the remaining ~75% look exactly as they do today | None -- explicitly the scoped trade-off (§4, Option A) |

---

## 6. Migration Path (for the implementing session)

Incremental, single-phase (no cutover risk -- this is an additive formula change behind an
existing gate, not a structural migration):

1. Change `derivedX()`'s B1 branch (`:795-797`) from `minSep * 0.4` to `minSep` (drop the `* 0.4`
   multiplier entirely -- no new constant is needed; §2.2's corrected target *is* the existing
   `minSep`, `:643`). If the implementing session's own live-render check (§7) finds `minSep` alone
   insufficient or unsafe, introduce a distinctly-named constant then, empirically justified by
   that finding -- not speculatively here.
2. Add a `qualifies()`-gated union-recentering step after Tier 3's B1 points are computed (Tier 2's
   loop, `:757-760`, needs the mate's finalized Tier-3 `x` first, so this must run *after* Tier 3,
   not inline within Tier 2 -- re-derive the exact control-flow ordering directly against current
   source at implementation time, not from this document's prose).
3. No change to B2/B3 logic, duplicate-node derivation, or the final de-collision sweep (§2.3).
4. **Rollback:** revert step 1-3's diff; this is a pure formula change with no schema/contract
   change, fully and independently reversible in one commit.

---

## 7. Verification Plan (for the implementing session)

- **Pre-RED empirical validation** (matching Track 6's own §1.4 methodology): before writing any
  test assertion, run the corrected formula live against the Track B fixture and the real
  375-individual fixture; confirm the qualifying-subset count (60/237, §1.4) is unchanged (this
  document's change must not alter *which* units qualify, only what `x` they get).
- **Collision-headroom check, live-rendered** (resolving §1.4's preliminary, unroot-caused
  finding): render the widened positions via the existing `chromote`-based live-render helper
  (`tests/testthat/helper-live-render-positions.R`, per Learning 641's own methodology) at the
  actual production `xScale`, and visually/programmatically confirm no unrelated node's rendered
  pixel position collides with a newly-widened mate -- not just raw-unit arithmetic.
- **Track 5 D1/D2 regression check:** run the existing `test_addRectilinearWaypoints.R`/
  edge-orthogonality suite unchanged; expect 0 new failures (proof-by-construction, §1.1/§2.4 --
  confirm, don't just assert).
- **Full clean regression** (`devtools::test()` / the project's own clean-regression-read command)
  -- 0 new failures/errors attributable to this change.
- **Visual re-verification:** regenerate and visually inspect (not just node-count-assert) the
  Track B full-fixture images in `kinship2-fidelity-validation.qmd`, matching the "verify diagrams
  against ground truth" standard this project already applies.
- `lintr::lint_package()` (loaded first, per this project's Lint close-out checklist) -- 0 new
  lints.

---

## 8. Explicitly Out of Scope (report, don't fix here)

- **Generalizing this fix beyond `qualifies()`-gated units** (Alternative B, §4) -- would require
  its own dedicated measurement session in Track 6's own style (a fresh empirical pass measuring
  the actual regression risk for polygamous anchors under a widened/recentered formula), not
  assumed safe by extension from this document's own proof-by-construction argument, which applies
  only to the disjoint qualifying subset.
- **The general epsilon-nudge/pixel-rounding pattern** Learning 641 documented across the rest of
  the codebase (every other Tier 2/Tier 3 tie-break sweep, the OLD algorithm's own equivalent) --
  this document resolves the one specific instance the owner flagged (the mating-unit dot on its
  anchor, for qualifying pairs), not the general pattern everywhere it appears.
- **Root-causing the preliminary collision-headroom finding** (§1.4) beyond reporting it -- flagged
  for the implementing session's own live-render verification (§7), not chased down here.
- **Any change to `.positionTreeApportion()`'s own BJL engine** -- this document touches only the
  pedigree-specific adapter's own downstream formulas, never the generic tree-apportion algorithm
  itself.

---

## 9. Post-draft adversarial verification (this session)

Before presenting this document for ratification, a 4-agent adversarial-verification workflow
independently re-checked every citation and quantitative claim against primary sources (not this
document's own prose) -- this project's own established practice of not trusting a citation without
checking it, applied to this document's own first draft, not only to prior sessions' work.

**What it found, and how each was handled:**

- **1 material finding that changed a recommendation:** kinship2's real, achieved spousal
  separation is exactly `1.0` raw unit (the ordinary adjacency floor), never the `1.414` an earlier
  draft claimed -- `align[2]` is a penalty *weight*, not a target *distance*. Independently
  re-confirmed directly (not merely trusted) by running `kinship2::align.pedigree()` on a hand-built
  trio while sweeping `align[2]` from `0.001` to `1000`: the achieved gap never moved off `1.0`.
  **Correction applied:** §1.4/§2.2/§3 rewritten -- the recommended target is now `minSep` itself
  (a single, well-justified constant), not an unpinned `0.75`-`1.4` range anchored on the wrong
  figure.
- **1 material citation error with no effect on the conclusion:** the Track 5 D1/D2 orthogonality
  citation (`:1533-1535, 1561-1563`) was copied verbatim from Track 6's own plan without
  re-verifying against current source, and doesn't actually support the claim at that location. The
  underlying invariant is still true (re-confirmed at the correct lines, `:1440-1487` and `:1526`).
  **Correction applied:** §1.1 citation fixed, with the error disclosed rather than silently
  swapped in.
- **3 minor findings, no material effect:** two backtick-quoted formulas dropped the source's
  `unname()` wrapper / renamed a variable; one quoted `2` where source has the integer literal
  `2L`; Track 6's own ratified formula was attributed loosely as "mean of children" when Track 6
  itself specified a min/max-of-extremes midpoint (today's shipped code, from the later Walker/BJL
  migration, is what actually computes a mean). **Correction applied:** all 3 fixed for precision.
- **0 discrepancies:** the empirical fixture measurements (Track B 4/4 qualifying; real fixture
  60/237 qualifying, 22/209 polygamous anchors) were independently reproduced exactly, including
  cross-corroboration against an existing, already-CI-verified test assertion
  (`test_buildMatingUnitForest.R`'s own `multiAnchor` set) neither this document's own research nor
  the verifying agent had to construct from scratch.

This section is left in place as a permanent record of what a first draft got wrong and how it was
corrected -- matching this project's own standing practice of disclosing errors rather than quietly
revising them away (e.g. the S645 post-close-out caption correction, `SESSION_NOTES.md`).

---

## 10. Owner ratification record

**Ratified 2026-08-27, session S646, via `AskUserQuestion`.** Presented 3 options -- (A) ratify as
scoped (§2's `qualifies()`-gated widen-to-`minSep` + recenter), (B) go broader now (drop the
`qualifies()` gate, all 237 units, accepting the reintroduced polygamous-anchor regression risk),
(C) hold / discuss trade-offs first. **The owner picked Option A, as scoped, with no changes.**

Both alternatives were live options, not straw men: (B) remains available as a genuinely separate,
future, higher-risk item (§4/§8), not foreclosed by this decision, if the ~25%-coverage boundary
(§1.4) later proves insufficient in practice. Nothing in the ratified scope changed as a result of
this decision -- §2's recommendation is adopted verbatim.

**Status: DESIGN RATIFIED. Ready for a Phase 1 implementation session** (TDD-gated RED/GREEN/
REFACTOR, per this project's Development Process Contract), following the Migration Path (§6) and
Verification Plan (§7) above.

---

## 11. Post-ratification correction (Phase 1 implementation, S647)

Matching this document's own §9 practice of disclosing errors rather than quietly revising them
away: implementation found that **§1.4's "60 of 237 anchored units (25.3%) qualify" measured
`qualifies()` in isolation**, not the actual gate the shipped mechanism uses. `derivedX()`'s Tier-3
B1 branch (and, by the same reuse, Track 7's own recenter) has always additionally required the
non-anchor member to be a genuine free-pass B1 individual (`for (fp in b1Ids) { if
(qualifies(unitId)) ... }`, pre-existing, unchanged by this document) -- a member can satisfy
`qualifies()`'s own `mateCountM == 1` conjunct while still having her own parent edge elsewhere
(making her B2, not B1), in which case the union is `qualifies()`-shaped but is never reached by
the recenter loop at all. Measuring the real fixture the way the code actually gates gives **34/237
(14.3%)**, not 60/237.

**What this does and does not change:** the ratified decision (Option A, §2's formulas, the
`qualifies()` gate as the safety boundary) is unaffected -- this is a correction to a supporting
coverage measurement, not to the approach. Track B (the fixture the owner actually observed) is
**unaffected**: 4/4 qualify either way, confirmed directly. `PROJECT_LEARNINGS.md` records this
finding as a session learning; `tests/testthat/test_positionMatingUnitForest.R` asserts the
verified 34, not the plan's original 60.

**A genuine new collision class, found via this implementation pass and taken through 3
iterations before landing (all measured live, none guessed):**

§2.3 assumed the existing de-collision sweep already "correctly handle[s] whatever `x` values
Tier 2/Tier 3 hand them" -- true for Tier 2, not for Tier 3's B1 output, which no sweep had ever
compared against `tier1X`/`unitX`. Widening the B1 offset to `minSep` (this project's own standard
inter-node spacing) turned this pre-existing gap into a routine exact-position collision (24 pairs
on the real fixture) -- two full-sized circles rendering almost entirely overlapping, confirmed via
an actual chromote render (`vignettes/articles/kinship2-fidelity-validation-img/
trackB-nprc-shrunk.png`'s own P2/C4 pair), not assumed from raw-unit arithmetic alone.

1. **First attempt** -- extend the sweep's comparison set to include `tier1X`/`unitX`, using the
   same `1e-3` tie-breaking epsilon already used elsewhere. Fixed the exact-tie case, but a `1e-3`
   gap between two full-sized circles is visually indistinguishable from a real overlap -- it
   solves the *coordinate* collision, not the *visual* one.
2. **Second attempt** -- push a colliding individual-shaped point a full `minSep` away instead
   (matching Tier 1's own `sweepMinSep()` guarantee for real individuals), always in the same
   direction as its own formula's sign (a same-direction-only push was found, mid-session, to
   sometimes cross a mate to the WRONG side of her anchor -- issue #145's male-left/female-right
   convention -- so the final version searches both directions, preferring the original sign only
   when tied). This eliminated the circle-on-circle overlaps, but on the real fixture's densely
   packed 173-founder gen-0 row, a small number of pairs needed many consecutive pushes (up to 23,
   drift up to 11.5 raw units) to clear -- and that displacement was found, by re-running the full
   regression suite, to create NEW, substantially worse collisions elsewhere:
   `.addRectilinearWaypoints()`'s separately-tracked D1 sibling-bar-vs-bar overlap count jumped
   from 0 to 34, several 400-540px wide (confirmed via `.findEdgeNodeCollisions()`, not assumed).
3. **Third attempt, shipped** -- cap the search at `.kMaxIndividualPush = 2` steps each direction;
   if nothing frees up within the cap, fall back to the *original* small exact-tie collision rather
   than an unbounded drift. This is a deliberate, owner-directed trade-off (via `AskUserQuestion`,
   presented with the measured 34-bar-overlap regression as evidence): a small, bounded residual of
   near-coincident individuals is preferable to occasionally spraying a founder pair across the
   whole diagram to chase a perfect fix. Net result on the real fixture, measured directly: 27
   nodes (13 pairs + 1 triple) still exact-tie (down from 24 pairs before this fix existed at all,
   not zero), and the D1 bar-overlap count settles at 5 (1 real 59.88px case, 3 sub-pixel, 1
   boundary touch) -- both disclosed in their own tests' comments, not hidden.

**A fourth, related pattern found but deliberately NOT fixed this session** (owner-directed,
`AskUserQuestion`): a mating-UNION dot (not an individual) can also land immediately adjacent to an
unrelated individual (e.g. the Track B "shrunk" fixture's own `P1`x`P2` union sitting 0.12px from
`C4`'s square) -- the *same* root tension (minSep-scale spacing creates frequent near-coincidences
in a dense pedigree), surfacing in the one collision shape this session's fixes deliberately left at
the pre-existing "weaker guarantee for dots" posture (§2.3). Given 3 iterations were already needed
to get the individual-circle case right, and each one surfaced a new case elsewhere, this is
filed as its own `BACKLOG.md` item (top priority, pending the standing pedigree-fidelity directive)
for a **dedicated future session** -- not attempted inline here, to avoid a 4th compounding
iteration in an already-long session (`SESSION_RUNNER.md`'s own "after 2 failed attempts, stop and
return to research" anti-pattern).

**A fifth pattern, found by the owner directly reviewing the regenerated Track B image, and
confirmed against kinship2's own reference rendering (owner-directed: document, do not fix
this session):** recentering a qualifying union between its two parents (§2.1) decouples its `x`
from its own children's positions -- something the OLD `mean(children)` formula guaranteed could
never happen. Concretely, on the Track B full fixture:

- `P3`x`P4` -> `C4` and `C4`x`P6` -> `C4a` (each a single-child union): before Track 7, a
  single-child union's `x` was *always* exactly its one child's `x` (the mean of one value), so the
  descent line was always a straight vertical drop. Track 7's recenter formula has no relationship
  to the child's position at all -- the union now sits wherever the anchor/mate midpoint lands, and
  `.addRectilinearWaypoints()` correctly inserts a right-angle dogleg to connect the two, because
  they are no longer at the same `x`.
- `M1`x`G3` -> `L1`/`L2`/`L3` (a 3-child union): the union's `x` (`3.5`, the parent-midpoint) no
  longer equals the children's own mean (`3.0`), so the drop point lands off-center on the sibship
  bar instead of at its middle -- no dogleg needed (the bar mechanism absorbs it), but visibly
  off-center.

**Confirmed directly against `trackB-kinship2-full.png`** (kinship2's own rendering of the
identical fixture, already committed in this repo): kinship2 shows *perfectly straight* vertical
drops for both single-child cases and a drop landing exactly at the `L1`/`L2`/`L3` bar's center.
kinship2 achieves both spousal separation AND undistorted descent lines simultaneously because its
`alignped4()` solver (§1.4) positions every individual -- parents AND children -- in one joint
optimization; it is free to adjust where a child sits, not just where a parent sits. This project's
Walker/BJL engine is fundamentally different: it positions children first, top-down and
recursively (Tier 1), then derives a qualifying union's position from its *already-fixed* parents
(Track 7's own Tier 2 override) -- it cannot reach back and move the children to match. Porting
kinship2's actual joint-optimization mechanism to eliminate this was already considered and
rejected in §3/§4 (Alternative C) as disproportionate to a cosmetic spacing complaint; this finding
is evidence for, not against, that same conclusion -- the tension is structural to the chosen
architecture, not a defect introduced by an implementation mistake, and a real (if partial) fix
would mean reopening exactly the migration §4 already declined. Filed for disclosure alongside the
4th finding above, not fixed this session.

---

## 12. Phase 2 design: union-dot proximity to unrelated nodes (session S648)

**Origin:** §11's 4th finding (owner-directed defer, S647) and `BACKLOG.md`'s own "Up Next"
item (Phase 2, standing top priority). This section is that dedicated future session, following
this document's own `ARCHITECTURE_WORKSTREAM.md` precedent (§ header) -- a scoping/design
session; **implementation is a separate future session** (the vertical-slice gate requires a
pre-declared contract from a *prior* session, which this section now provides).

### 12.1 Fresh evidence gathered this session (Pre-RED, not assumed from §11's single example)

Measured directly via `pkgload::load_all()` + `.buildMatingUnitForest()` +
`.positionMatingUnitForest()`, called live against current `HEAD` (commit `95eedad4`), not read
from §11's prose:

- **This is a Phase-1-introduced regression, not only a pre-existing gap.** Temporarily checking
  out the pre-Track-7 source (`git show 6d4ad111:R/makePedigreeDiagramData.R`, the commit
  immediately before Phase 1's own diff) and re-running the identical measurement: **only 1 of
  237 mating unions** (`__union_162`, already the one case §1.4's own preliminary probe reported)
  had a nearest-neighbor distance under a visual-overlap threshold. Under Phase 1's shipped code,
  **20 of 237 (8.4%)** do. Phase 1's own widen-to-`minSep` change is the direct cause of 19 of the
  20 -- confirmed by direct before/after comparison on the identical fixture, not inferred.
  (File restored byte-identical to `HEAD` immediately after this comparison; `git status` clean
  throughout, confirmed.)
- **Threshold used:** the nearest *other* node (excluding the union's own anchor/mate, which are
  expected to sit close post-Track-7 -- that is Phase 1's own fix) is "overlapping" when their
  center-to-center distance is under the sum of the two nodes' own rendered radii --
  `size = 25` for a real/duplicate node, `size = 6` for a union dot (`R/makePedigreeDiagramData.R:
  1306/1324/1342`), i.e. 31px (0.258 raw units at `xScale = 120`) against an individual/duplicate,
  12px (0.1 raw units) against another union.
- **Magnitude is bounded, unlike Phase 1's own individual-circle problem.** Of the 20 overlapping
  cases: 15 sit at the pre-existing `1e-3`-raw-unit tie-break epsilon (0.12px -- the literal "weaker
  guarantee for dots" residual §2.3/§11 already named), 5 sit in an 11.88-30px band (a genuinely
  different magnitude, not the epsilon floor) -- **the worst case across all 237 units is 30px**,
  never approaching the multi-hundred-px drift Phase 1's own individual-circle fix had to cap
  (`.kMaxIndividualPush`, up to 5.5 raw units / 660px on the real fixture). 5 of the 20 are mutual
  union-vs-union pairs (both sides read each other as nearest); the remaining are union-vs-
  individual/duplicate.
- **Track B, corrected (self-correction, found while preparing visual comparisons for
  ratification -- see below): the FULL 16-subject fixture measurement above was wrong, not
  merely imprecise.** `makePedigreeMatingLayout()` pre-filters fully-isolated individuals
  (`.findIsolatedIds()`, `R/makePedigreeDiagramData.R:1145-1146`, the P5-suppression item) BEFORE
  positioning -- calling `.buildMatingUnitForest()`/`.positionMatingUnitForest()` directly on the
  unfiltered full fixture, as this section originally did, measures a pedigree
  `makePedigreeMatingLayout()` never actually produces. The full fixture's own `P5` is isolated
  (zero edges, by design -- it is the P5-suppression item's own test case); once correctly
  filtered, the full fixture has **0 of 4 unions overlapping**, not 1 -- the `__union_2`/`P5`
  case this section originally reported is not present in anything that ships.
  **The fixture that IS the correct point of comparison is the "shrunk" 8-subject fixture**
  (`shrinkPedigree(pedB, ..., maxBits = 1L)$ped`, the input to the already-committed
  `trackB-nprc-shrunk.png` -- `data-raw/kinship2FidelityValidation.R:207,244,246`), which has
  **zero isolated ids** (confirmed directly -- no filtering discrepancy possible) and is the
  fixture S647's own §11 4th finding actually cited. Correctly measured, matching production
  exactly: **all 3 of 3 mating units overlap** (`__union_1` C4xP6/nearest P2, `__union_2` P1xP2/
  nearest C4 -- the exact pair §11 cited, confirmed -- `__union_3` M1xG3/nearest C4a), all 3 at
  the same 0.12px epsilon floor. **Pre-Track-7 baseline on this same shrunk fixture (re-verified
  via the identical temporary-swap-and-restore method as the real-fixture check above): 0 of 3
  overlap** (72-120px separation) -- Track 7 Phase 1 took this specific, already-visually-reviewed
  fixture from a clean 0/3 to a uniform 3/3, a materially stronger and cleaner regression signal
  than the real 375-fixture's own 1-in-237-to-20-in-237 finding. The real-fixture measurement
  itself is unaffected by this correction (confirmed separately: the real fixture has 0 isolated
  ids, so no filtering discrepancy applies there).
- **Preliminary push simulation** (matching §1.4's own "preliminary, not a full live-render
  check" depth, not the implementing session's own obligation below): simulating a capped
  bidirectional push of each colliding union, at a *radius-proportionate* clearance target
  (0.258 raw units, derived from the two node sizes above, not the flat `minSep` individuals use)
  rather than reusing `minSep` verbatim -- **18 of 20 resolve within 2 push-steps, all 20 resolve
  within 5**; the resulting shifts are 31-62px (worst case), an order of magnitude gentler than
  Phase 1's individual-circle fix; **0 cases introduced a new point-level coincidence** with a
  different same-gen node in this naive check. This is a point-distance simulation only -- it does
  **not** check sibship-bar-span-vs-bar overlaps (`.addRectilinearWaypoints()`'s own D1 geometry,
  which Phase 1's own v2 attempt found the hard way can regress from a seemingly-safe point-level
  fix) -- that check is explicitly the implementing session's own obligation (§12.6), matching
  Phase 1's own division of labor between design-stage probe and implementation-stage live-render
  verification.
- **A structural fact this session confirmed by reading source, not assuming:** for the common
  case, a moved union's `x` directly repositions its own `__drop_<unionId>` sibship-bar waypoint
  (`R/makePedigreeDiagramData.R:1642-1649`, `barPointX <- c(unname(xOf[[fromId]]), ...)`) --
  moving a union to resolve a dot-proximity collision necessarily reshapes that union's own
  sibship-bar span. (Precision note, found by this session's own adversarial verification: the
  enclosing loop is `for (fromId in unique(childEdges$from))`, and per
  `.buildMatingUnitForest()`'s own documented contract, `fromId` is a mating-unit id in the common
  case but can be a single real individual's id under the D5 partial-parentage fallback -- so
  "a mating union's own x" describes the common case this decision targets, not an unconditional
  invariant of the loop itself. Does not affect this document's own scope, which only ever
  concerns unions.) This is the same class of cross-function interaction Phase 1's own v2 attempt
  hit for individuals (§11) and is why §12.6 requires the same live-render D1 regression check
  Phase 1's own §7 required, not a lighter bar for this narrower-looking problem.
- **The existing mechanism already treats unions as structurally weaker, on both sides, by
  design, not by oversight:** `.deCollideIndividualPoints()` (the shared sweep governing B1/B3
  individual-shaped points) never adds `unionOccupied` to its main capped-search `forbidden` set --
  only its residual epsilon pass checks `tiesUnion`. The mirror-image union-side sweep
  (`R/makePedigreeDiagramData.R:981-1001`) already DOES compare a union's `x` against `tier1X`,
  B1's own final `tier3X` at that gen (added S647, `b1AtGen`), and every other already-placed
  union at that same gen from earlier in this same loop (`placedAtGen[[g]]` -- found by this
  session's own adversarial verification; the design's own text below undersold this, omitting
  the `placedAtGen` term) but only ever nudges by the same `1e-3` epsilon on an exact tie -- it
  never performs a real push. **This document's own scope is
  the union side only** (§12.2) -- symmetric hardening of the individual side is considered and
  rejected as disproportionate (§12.4, Alternative D).

### 12.2 Decision

Replace the union-position sweep's exact-tie-only epsilon nudge
(`R/makePedigreeDiagramData.R:996-998`) with a capped bidirectional search, structurally the same
shape as Phase 1's own `.deCollideIndividualPoints()` (§11), but:

1. **Triggers on a radius-proportionate clearance threshold, not an exact-tie epsilon.** A new
   raw-unit constant, `unionClearance`, derived transparently from the two already-existing
   render-layer node sizes (`25` for a real/duplicate node, `6` for a union dot) and `xScale`
   (`120`) -- `(25 + 6) / 120 = 0.2583`, rounded to a named constant with its derivation shown in
   a comment, matching Phase 1's own "well-justified, not guessed" bar (§2.2). A union-vs-union
   comparison uses the smaller `(6 + 6) / 120 = 0.1` -- both derived the same way, from the same
   two existing constants, no new guess.
2. **Pushes by that same proportionate step, not a flat `minSep`.** A union is a much smaller
   visual object than a real/duplicate node (`size = 6` vs. `25`); reusing individuals' flat
   `minSep` (`120`px) would move a union roughly 4x farther than the minimum needed to clear the
   collision -- unnecessary added distortion to the sibship-bar span this union's own `__drop_`
   point drives (§12.1's structural finding), for no additional benefit.
3. **Capped, with a fallback to the current epsilon-nudge behavior if nothing frees up within the
   cap** -- same disclosed-residual shape Phase 1established (§11), not a silent unbounded
   search. §12.1's preliminary simulation resolved 18/20 real cases within 2 steps and all 20
   within 5; the implementing session's own live-render check (§12.6) determines and empirically
   justifies the final cap value, exactly as Phase 1's own `.kMaxIndividualPush = 2` was chosen
   empirically, not speculatively here.
4. **Individuals/duplicates are entirely untouched** -- `.deCollideIndividualPoints()` itself, its
   own forbidden-set construction, and Tier 1's `sweepMinSep()` backstop are unmodified. This
   fix is scoped to the union side only, mirroring Phase 1's own additive, single-side scoping
   discipline (§3).

### 12.3 Rationale

The union sweep already reads both `tier1X` and B1's own final `tier3X` at each gen (S647) --
the machinery to KNOW about a collision already exists; it just never acts on anything short of
an exact tie. This decision reuses that existing detection, replacing only the response (a real,
capped, proportionate push instead of an epsilon nudge) -- the same "widen within an existing,
already-trusted boundary" ethos Phase 1's own §3 used, applied to the mirror-image side of the
same sweep. A radius-proportionate target (not `minSep`) keeps the fix honestly scaled to the
actual visual object being moved, minimizing collateral distortion to the sibship-bar geometry
that object's own position also drives.

### 12.4 Alternatives Considered

| Alternative | Pros | Cons | Why Rejected / Deferred |
|---|---|---|---|
| **A. RECOMMENDED -- capped bidirectional push at a radius-proportionate clearance (§12.2)** | Reuses an already-detecting mechanism; smallest sufficient movement (31-62px worst case, per §12.1's simulation); scoped to the union side only | Still needs the implementing session's own full live-render D1 regression check (§12.6) before shipping, same as Phase 1 | -- (this is the recommendation) |
| **B. Reuse the flat `minSep` push, mirroring Phase 1's individual-side mechanism verbatim** | Simpler: one shared constant, one shared code path for both sides | Moves a union ~4x farther than the minimum needed (120px vs. 31px), for a visual object 4x smaller than the individuals `minSep` was sized for -- larger, unnecessary sibship-bar-span distortion for the identical result | **Rejected** -- disproportionate to the object being moved (§12.3) |
| **C. Shrink the union dot's own rendered `size` instead of moving any position** | Zero risk to `.positionMatingUnitForest()`, Track 5 D1/D2, or any positioning invariant | Does not fix the 15 exact-tie-epsilon cases (0.12px) at all -- a smaller dot still visually sits ON/inside an unrelated node's own circle when its center is nearly coincident with that node's; only narrows the OVERLAP AREA for the 5 non-epsilon cases, not the underlying "sits on an unrelated node" defect the owner would still see | **Rejected** -- does not address the actual complaint for the majority (15/20) of measured cases |
| **D. Also harden the individual/duplicate side to avoid unions (`.deCollideIndividualPoints()` adds `unionOccupied` to its own forbidden set)** | Fully symmetric guarantee; would additionally resolve the case where an unrelated individual is the one that should move | Reopens a mechanism Phase 1 only just shipped and fully tested (§11) for a cosmetic dot-adjacency problem on the OTHER side of the same sweep -- disproportionate blast radius; the union side alone already resolves every case in §12.1's measurement (a union has freedom to move without displacing any real individual's own already-correct position) | **Deferred** -- not needed by the evidence gathered (§12.1); revisit only if a future measurement finds a case the union-only fix cannot resolve |
| **E. Conditionally skip Track 7's own recenter (§2.1) for a qualifying unit whose recentered position would collide, falling back to the old child-mean formula for that unit only** | Avoids ever moving a union post-recenter at all | Reintroduces exactly the "some qualifying units recenter, others silently don't, depending on incidental collision" inconsistency Phase 1's own consistent, unconditional formula (§2.1) was built to avoid; would still leave the ONE pre-existing pre-Track-7 case (`__union_162`, §12.1) unaddressed, since that case predates recentering entirely | **Rejected** -- inconsistent, and does not even fully solve the problem it targets |

### 12.5 Impact Analysis

| System / surface | Impact | Action Required |
|---|---|---|
| Union-position sweep (`R/makePedigreeDiagramData.R:981-1001`) | Exact-tie-only epsilon nudge replaced with a capped, proportionate-clearance bidirectional push | Implementing session's own RED/GREEN |
| `.deCollideIndividualPoints()`, Tier 1 `sweepMinSep()`, B1/B3 individual formulas | **No change** -- this decision touches only the union-side sweep | None |
| Track 5 D1/D2 edge orthogonality | Unaffected by construction -- D1/D2 read a union's `x` generically, same proof as Phase 1's own §2.4/§1.1 | Re-confirm via the existing D1/D2 test suite, not a new analysis |
| D1 sibship-bar geometry (`__drop_<unionId>` waypoint, `:1642-1649`) | **New interaction, not present for Phase 1's own individual-side fix**: a pushed union's `__drop_` point moves, reshaping that union's own bar span | Implementing session's own live-render D1 regression check (§12.6) -- mirrors, but does not reuse, Phase 1's own v2-attempt lesson |
| `qualifies()`-gated recenter (§2.1) | **No change** -- this decision does not alter which unions qualify or what their pre-collision-avoidance `x` is, only whether/how far a colliding result gets nudged afterward | None |
| `test_positionMatingUnitForest.R`'s own 27-node exact-tie regression test (§11) | The 27-count includes some of the same union-involving pairs this decision targets -- expect that count to change (likely decrease) once implemented | Implementing session: re-measure, do not assume 27 is still correct |
| Real-colony rendering | 20/237 unions (8.4%) visibly change position by 31-62px; the remaining 217 are untouched | None -- scoped, disclosed trade-off |

### 12.6 Verification Plan (for the implementing session)

- **Pre-RED empirical re-validation**, matching §12.1's own methodology: re-run the identical
  before/after measurement live against the implementation's own working tree (not carried
  forward from this document) -- confirm the 20-case count and magnitudes are still current
  (the codebase may have changed between this design session and implementation).
- **Live-rendered D1 regression check, MANDATORY, not optional** (this is the one respect in
  which Phase 2's risk profile, while smaller in raw magnitude than Phase 1's, is NOT simpler in
  kind): render the pushed positions via the existing `chromote`-based live-render helper and
  `.findEdgeNodeCollisions()`, checking specifically for NEW sibship-bar-vs-bar or bar-vs-node
  overlaps the push introduces -- §12.1's own structural finding (a moved union reshapes its own
  `__drop_` waypoint) means this is not a hypothetical risk to rule out, it is a confirmed
  mechanism to verify against, exactly as Phase 1's own v2 attempt discovered live rather than by
  reasoning alone.
- **Re-run `test_positionMatingUnitForest.R`'s existing 27-exact-tie-count assertion (§11)** and
  update it to whatever the new, empirically-measured count is -- do not assume it is unaffected.
- **Full clean regression** -- 0 new failures/errors attributable to this change.
- **Visual re-verification**: regenerate and visually inspect the Track B images (the 1 affected
  union, `__union_2`), matching this project's "verify diagrams against ground truth" standard.
  Given Learning 681's own lesson (S647 post-close-out), explicitly check for the SAME class of
  side effect Learning 681 named -- does the push change what an OLD mechanism guaranteed as a
  side effect (e.g. a previously-straight descent line) -- not only the collision this fix
  targets.
- `lintr::lint_package()` (loaded first) -- 0 new lints.

### 12.7 Explicitly Out of Scope (report, don't fix here)

- **§11's 5th finding** (union/children decoupling, single-child dogleg / off-center sibship bar)
  -- a separate, already-disclosed architectural tension (local-vs-global positioning), not
  addressed by this document; a future session should read both findings together before any
  further work in this area, since a union-position push (this document) could interact with that
  tension (e.g. a pushed union's descent-line dogleg direction/length) -- flagged for the
  implementing session's own visual re-verification (§12.6), not resolved here.
- **Symmetric individual-side hardening** (Alternative D, §12.4) -- deferred, not needed by
  current evidence.
- **The general epsilon-nudge/pixel-rounding pattern** elsewhere in the codebase (Learning 641,
  carried forward from §8) -- this document resolves the one instance the owner's own
  visual review flagged (union dots on qualifying pairs), not the general pattern.

### 12.8 Post-draft adversarial verification (this session)

Matching §9's own established practice: before presenting this document for ratification, a
3-agent adversarial-verification workflow independently re-derived every quantitative claim in
§12.1 (the pre-Track-7-vs-current regression count, the push-simulation resolve counts) from
scratch -- own scripts, own methodology, not copying this document's own scratch scripts -- and
independently re-checked all 4 source-code citations underpinning §12.1's structural findings.

**What it found, and how each was handled:**

- **Both quantitative claims CONFIRMED exactly**, including every subsidiary number (the 1/237
  pre-Track-7 count and its specific offending pair; the 20/237 current count and its 15-epsilon/
  5-band/5-mutual-pair breakdown; the 18-within-2-steps/20-within-5-steps/0-new-collisions push
  simulation result), independently re-derived from a fresh implementation of the described
  method, not by re-running this document's own scripts.
- **All 4 citations CONFIRMED**, with 2 precision nuances in this document's own prose (not
  factual errors in the underlying claims) -- both corrected in place above, disclosed rather than
  silently fixed, matching this project's own standing practice (§9; the S645 caption correction,
  `SESSION_NOTES.md`): (1) the `__drop_<unionId>` waypoint framing (§12.1) describes the common
  case, not an unconditional invariant of the enclosing loop, which can also run over a single
  real individual's id under `.buildMatingUnitForest()`'s own D5 partial-parentage fallback --
  immaterial to this document's own scope, which only ever concerns unions; (2) the union sweep's
  own `occupied` set (§12.1) also includes other already-placed unions from earlier in the same
  per-gen loop (`placedAtGen[[g]]`), which this document's prose had omitted alongside `tier1X`
  and B1's `tier3X`.
- **0 discrepancies** in the empirical measurements themselves -- both the regression-count and
  push-simulation verifications matched this document's own scratch-script results to the exact
  distance, union id, and count, using independently-written verification code.

**A separate, more significant error found AFTER this workflow ran, NOT caught by it** (disclosed
rather than silently fixed, matching §9's own standing practice): the workflow's
`regression-count` check was scoped, by this session's own prompt, to the REAL 375-individual
fixture only -- it never re-checked the Track B claim, which was wrong. While preparing visual
before/after comparisons for ratification (prompted by the owner asking to see the visual impact
before deciding), this session found that the original §12.1 Track B measurement called
`.buildMatingUnitForest()`/`.positionMatingUnitForest()` directly on the unfiltered FULL Track B
fixture -- a pedigree `makePedigreeMatingLayout()` never actually produces, since it pre-filters
`P5` (isolated, zero edges) before positioning. The correct comparison point is the "shrunk"
Track B fixture (zero isolated ids, no filtering discrepancy possible), on which the true finding
is **all 3 of 3 unions overlap** (not 1 of 4, and not the pair originally reported) -- see the
corrected §12.1 bullet above for the full detail and the pre-Track-7 baseline (0 of 3) re-verified
under it. **Lesson for this session, not yet promoted to `PROJECT_LEARNINGS.md`:** calling an
internal positioning function directly, bypassing a wrapper's own pre-filtering step, measures a
pedigree that wrapper never actually produces -- the same class of gap as testing a function in
isolation from the pipeline stage that changes its input. The real-fixture numbers this workflow
did verify are unaffected (confirmed separately: 0 isolated ids in that fixture).

### 12.9 Visual spike evidence (owner-requested, before ratification)

Per the owner's own request to see the visual impact of Option A vs. Option B before deciding,
this session rendered all three states via `makePedigreeMatingLayout()` + `visNetwork` +
`chromote` (matching `data-raw/kinship2FidelityValidation.R`'s own established rendering
methodology) on the shrunk Track B fixture (§12.1/§12.8's corrected fixture, all 3 unions
colliding under current shipped code). Each option was applied as a temporary, uncommitted patch
to `R/makePedigreeDiagramData.R` (backed up first via `cp`; restored immediately after each
render; `git diff`/`git status`/`shasum` confirmed byte-identical to `HEAD` after each restore,
matching the discipline already used for the pre-Track-7 baseline comparisons above) -- **no code
change from this section is committed; this is spike evidence only**, informing the ratification
choice below, not an implementation.

- **Baseline (current shipped code):** all 3 union dots render effectively fused into an
  unrelated node's own circle -- visually indistinguishable from a rendering artifact rather than
  a real marker (confirmed visually: a small notch/bite on the boundary of `P2`'s circle is the
  only visible trace of a union dot that should be its own distinct marker).
- **Option A (radius-proportionate capped push):** all 3 union dots become visible, distinct
  circles sitting in a small, real gap next to the node they were previously fused with -- no
  other change to the diagram's overall shape; edges route exactly as before.
- **Option B (flat `minSep` push):** the union dots do separate from their previous host nodes,
  but the ~4x larger push cascades into a visibly WORSE overall layout -- `P1` is pushed into
  visible isolation at the far left of its row with a long rectilinear detour edge required to
  reach its own child's row, an artifact not present in either the baseline or Option A's render.
  **This is a direct, visual confirmation of §12.3's own written concern** (a flat `minSep` push
  moves a union ~4x farther than necessary, risking collateral distortion elsewhere) -- not merely
  a theoretical risk, an observed one on the very fixture the owner has already reviewed.

This visual evidence is additional support for Option A over Option B beyond §12.1's own
point-distance simulation (which already found Option A's shifts gentler in magnitude) -- it shows
the SAME conclusion manifesting as an actual rendering artifact, not just a raw-unit measurement.

### 12.10 Owner ratification record (Phase 2)

*(To be completed once presented via `AskUserQuestion`.)*

## References

- `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` (child-centering
  rationale, the regression this document must not reintroduce)
- `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md` (Track 3 removal
  warning, D1/D2 orthogonality citations)
- `PROJECT_LEARNINGS.md` Learning 641 (epsilon-nudge/pixel-rounding pattern, `xScale = 120`)
- `PROJECT_LEARNINGS.md` Learning 640 (B1 free-pass nodes render under their own real id)
- kinship2 1.9.6.2 source, read directly this session: `alignped1()`, `alignped3()`, `alignped4()`,
  and the package's own bundled vignette `doc/align_code_details.Rmd` (installed package, `renv`
  library, this project's own R 4.6 environment)
- `BACKLOG.md` "Up Next" (this item's own filing, S645, with the empirical Track-B-fixture
  citations this document re-verified)
