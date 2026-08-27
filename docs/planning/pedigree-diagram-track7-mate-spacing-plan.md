# Pedigree Diagram Track 7: mate spacing and union centering for qualifying pairs

**Status:** DESIGN, session S646 (2026-08-27). **RATIFIED, session S646** (§10) -- Option A adopted
as scoped, no changes. Implementation not yet scheduled (a separate future session, per this
project's planning/implementation session boundary).

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
