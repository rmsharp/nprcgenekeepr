# Pedigree Diagram Track 6: child-centered mating-unit position

**Status:** DESIGN, session S576 (2026-08-14). **IMPLEMENTED, session S578 (2026-08-14)** --
matching Track 4's own design/implementation split (S572 design, S573 implementation). See
§10 for the implementation record, including 2 corrections Pre-RED empirical validation found
beyond this document's own §2.1 snippet.

**Origin:** `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §7b (found S575,
owner review of a published live-comparison artifact) -- filed as a `BACKLOG.md` Housekeeping item,
explicitly flagged there as needing its own dedicated design session because the change surface is
`.positionMatingUnitForest()`, the core recursive positioning algorithm shared by every diagram
render regardless of `edgeStyle`.

**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` (chosen over
`DESIGN_WORKSTREAM.md`, matching this project's own established precedent for pedigree-diagram
positioning-algorithm decisions -- S432's issue #129 plan, S458's Option 2 layout plan, S464's
rectilinear-waypoint plan, S471/S473's issue #143/#144 plans, and S572's Track 4 plan all made the
same call for the same reason: this is a technical/algorithm-correctness decision, not a
panel/visual-arrangement one).

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

- D1-D6 of the mating-unit-forest transformation and contour-merge positioning algorithm
  (`docs/planning/pedigree-diagram-option2-layout-design-plan.md`) are ratified and shipped; this
  document does not propose replacing the recursive contour-merge itself, only one specific
  sub-step within it (D3 step 4).
- Track 1 (unaffected fill), Track 2 (default `edgeStyle`), Track 3 (minimum mate-spacing sweep),
  Track 4 (gen-aware anchor selection), and Track 5 (rectilinear routing coverage, re-measured
  S575, 0 gap for its own narrow question) are all DONE and orthogonal to this decision:
  - Track 3's `sweepMinSep()` operates on `x` within a display row for **real and duplicate
    individual nodes only** -- union (`__union_*`) nodes are explicitly excluded from it today
    (`R/makePedigreeDiagramData.R:858-860`'s own comment: *"mating-unit dots are excluded; their x
    is a derived midpoint of their own 2 parents ... not an independently laid-out leaf"*). This
    document changes what that derived midpoint is derived **from**, not whether union nodes get
    swept.
  - Track 4 fixed which row (`gen`) a mating unit's anchor renders on. It did not touch **x**
    positioning at all. Fully orthogonal.
  - Track 5 established, as a structural invariant (not just empirically), that every child edge
    (D1) and every mate edge (D2) is orthogonal regardless of the union's `x` value -- D1
    unconditionally waypoint-routes every child edge, and D2's dogleg fires purely on `gen`
    inequality, never on `x` (`R/makePedigreeDiagramData.R:1533-1535, 1561-1563`). **This document's
    change cannot regress Track 5's own invariant** -- confirmed by reading the D1/D2 code directly
    this session, not re-measured empirically (unnecessary; the invariant is proof-by-construction
    and this decision touches neither D1 nor D2's own logic, only the `x` value they read).
- **D3 step 4 (`R/makePedigreeDiagramData.R:924`, "set each mating unit's final x to the midpoint
  of its two parents' x") is explicitly NOT protected as an immutable property of the ratified
  Option 2 design**, for the same reason Track 4's own plan established this for D2's
  gen-blindness (`docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` §1.1): the
  Option 2 plan's own citation for step 4 (*"the exact geometry S457's Case C2 already proved
  renders correctly in visNetwork with `visPhysics(enabled=FALSE)` + fixed coordinates +
  `smooth=FALSE` edges"*) is a proof about the **rendering mechanism** (fixed vis.js coordinates
  render correctly), not a proof that the specific midpoint-of-2-parents **formula** is the only
  legibility-preserving choice. This document reconsiders the formula; it does not reopen the
  fixed-coordinate rendering mechanism.

### 1.2 What this document decides

Two questions, both about `.positionMatingUnitForest()`'s final `x`-assignment for mating-unit and
duplicate nodes:

1. **What should a mating unit's final `x` be derived from** -- its two parents' positions (today),
   or its own children's positions (proposed)?
2. **Given (1), where should a duplicate node's `x` be anchored** -- it is currently derived
   pre-sweep from the union's own provisional (pre-final) position; does that still hold once (1)
   changes what "final" means?

### 1.3 Full history: how the current defect arose

`docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §7b (root cause, read
directly from `.positionMatingUnitForest()` this session, `R/makePedigreeDiagramData.R:584`
onward, current numbering):

- **The recursive descent positions every individual and mating unit relative to its own
  descendants, never its own mates.** `positionUnit()` centers a mating unit over the merged span
  of its own children (D3 step 2, already-ratified); `positionIndividual()` then centers an
  individual over the merged span of **every** mating unit they anchor, plus any direct child of
  their own. For an individual who anchors only one union (the common case -- see §1.4), this
  collapses to "centered over this one union's children," which already closely approximates a
  child-centered position. For a **polygamous** anchor (anchors 2+ unions), their own `x` becomes
  the centroid of **all** their unions' combined descendant subtrees -- pulled away from any one
  particular union's own children.
- **D3 step 4 then overrides the union's own provisional (children-centered) position with the
  midpoint of its two parents' positions** -- for a polygamous anchor, this substitutes the
  anchor's cross-union centroid for the union's own local position, decoupling the union from
  where its own children were positioned during the earlier descent.
- **D1's sibship-bar drawing (`R/makePedigreeDiagramData.R:1497-1524`) is what turns this into a
  visible defect.** For every mating unit, D1 draws a horizontal bar from a point directly below
  the union (`dropId`, at the union's own `x`) across to each child's `x`, sorted left-to-right.
  When the union sits far from where its children actually are, the segment between `dropId` and
  the nearest bar point is long -- exactly the *"horizontal lines connecting progeny from
  different parents"* the owner reported. Every individual edge stays orthogonal (Track 5's own
  invariant, unaffected) -- the defect is legibility (a technically-right-angle path traveling an
  unnecessarily long horizontal run), not a routing-correctness gap.

### 1.4 Fresh evidence gathered this session (not assumed carried forward)

Measured directly against the real 375-individual bundled fixture (`obfuscated_rhesus_mhc_ped.csv`)
via `.buildMatingUnitForest()` + `.positionMatingUnitForest(ped, forest, orderBySex = TRUE)`,
reproducing S575's own methodology exactly (confirmed: this session's script's raw-unit baseline
max, 89.1, times `makePedigreeMatingLayout()`'s own `xScale = 120L`
(`R/makePedigreeDiagramData.R:1151, 1287`), is 10,692 -- matching S575's reported 10,687 almost
exactly; the residual is the `orderBySex` swap, applied after the positions this measurement reads).
**"251 child-edge groups" (S575's own phrase) is `nrow(forest$childEdges)` exactly -- one row per
individual union-to-child edge (this fixture has 237 mating units producing 251 total child edges;
some units have 2-3 children), not one row per union** -- worth stating explicitly since a
per-union grouping would silently undercount.

- **Baseline (shipped code) reproduced exactly:** of 251 child edges, 100 (39.8%) exceed a
  200-scaled-unit horizontal offset, 73 (29.1%) exceed 500, max 10,687.6. Matches S575's reported
  figures to within rounding.
- **Candidate A alone (§2.1, recompute the union's `x` as the midpoint of its own children's
  min/max final `x`):** 9 of 251 edges (3.6%) exceed 200, 8 (3.2%) exceed 500, max 4,121.25 -- a
  91% reduction in violating-edge count and a 61% reduction in the worst case.
- **The 9 residual edges are NOT a partial failure of this fix -- they trace to a distinct,
  separate phenomenon**, confirmed by direct inspection: each belongs to a mating unit with only
  2-3 children whose own **descendant-subtree sizes differ so much that the children themselves end
  up far apart in `x`**, independent of where the union sits. Example (`__union_15`, gen 0): its 2
  children sit at raw `x` 29.88 and 98.56 -- a 68.68-raw-unit gap between **direct siblings**, more
  than half the entire fixture's own raw-`x` range (-0.5 to 128.3). No possible union position
  between 2 children that far apart can keep both offsets under 200 units; the union is not
  misplaced, the sibship itself needs more width than a single point can straddle within the
  threshold. This is the same "centered over one's own descendant subtree, not one's local
  neighbors" pattern recurring one level down the recursion -- a structural property of the
  recursive contour-merge (D3, already-ratified), not something this decision's own scope (union
  vs. its **immediate** children) can or should absorb. Flagged as explicitly out of scope, §8.
- **A side effect not anticipated before measuring:** recomputing the union's `x` from its children
  **severs** the relationship the current code accidentally maintains between a union and its own
  duplicate (non-anchor) parent node, because `dupX` (`R/makePedigreeDiagramData.R:842-845`) is
  today computed from the union's **pre-sweep provisional** position, and the *shipped* `finalUnitX`
  formula (`= (anchorX + nonAnchorX) / 2`) already averages toward `dupX` when a duplicate exists --
  keeping them close (baseline duplicate-to-union distance: mean 61.94, max 120.12 scaled units).
  Under Candidate A alone, with that averaging removed, mean duplicate-to-union distance measured
  849.13, max 10,567.50 -- reintroducing essentially the same class of defect this decision exists
  to fix, just on the non-anchor-parent side instead of the child side. **Extended Candidate A
  (§2.2)** recomputes `dupX` from the *new* `finalUnitX` instead, restoring D3 step 5's own stated
  intent (*"positioned immediately adjacent to their mating unit"*) exactly: mean/max
  duplicate-to-union distance both measured 48 scaled units (`minSep * 0.4 * xScale`), tighter than
  even the baseline. This does, however, require removing `dupX` from Track 3's `sweepMinSep()`
  input (since a swept value would just be overwritten by the new formula) -- measured on the real
  fixture, this creates exactly 1 exact-coincidence collision (a duplicate node landing precisely
  on top of an unrelated same-row node) that Track 3's sweep would previously have prevented but the
  existing final de-collision pass (`R/makePedigreeDiagramData.R:936-954`) does not currently reach,
  because it explicitly excludes duplicate ids (`isDuplicate <- nodes$id %in% duplicates$id`). A
  1-line broadening of that pass's own exclusion (**Extended Candidate A §2.3**) -- confirmed by
  measurement -- closes it (worst same-gen gap after: 0.001, matching the exact epsilon-nudge value
  that pass already uses elsewhere for real/union coincidences) with **zero change** to the primary
  result (still 9/251 edges >200, max 4,121.25; duplicate-to-union distance still 48/48).

---

## 2. Decision

**Adopt Extended Candidate A**, three coordinated changes to `.positionMatingUnitForest()`
(`R/makePedigreeDiagramData.R:584` onward, current numbering):

### 2.1 Recompute `finalUnitX` from the union's own children, not its two parents

Replace the current `finalUnitX` loop (`:896-926`, which reads `anchorX`/`nonAnchorX` and averages
them) with:

```r
finalUnitX <- numeric(nrow(matingUnits))
if (nrow(matingUnits) > 0L) {
  for (i in seq_len(nrow(matingUnits))) {
    unitId <- matingUnits$id[i]
    kids <- childEdges$to[childEdges$from == unitId]
    # Every mating unit has >= 1 child by construction (.buildMatingUnitForest()
    # only synthesizes a unit from an observed child row) -- no empty-kids
    # fallback needed. Reuses realX, already Track-3-swept at this point in the
    # function (sweepX/realX assigned just above, :892-893) -- the SAME
    # midpoint-of-merged-span formula D3 step 2 already uses for the
    # PROVISIONAL position (:679-688 finalizeNode()), just applied again here
    # to the FINAL (post-sweep) child positions instead of overridden by the
    # parents' midpoint.
    kidX <- realX[kids]
    finalUnitX[i] <- (min(kidX) + max(kidX)) / 2L
  }
}
```

This drops the `anchorX`/`nonAnchorX`/`dupRow`/orphan-unit special case entirely: an orphan unit
(issue #154, both parents dangling) already has real children like any other unit, so it needs no
special-casing under the new formula -- a net simplification, not just a substitution (mirrors
Track 4's own §3 rationale: *"a decision that structurally closes a defect class is preferred...
when net simplification, not net addition, is the result"*).

### 2.2 Recompute `dupX` from the new `finalUnitX`, not the pre-sweep provisional position

Move the `dupX` computation (`:842-845`) to **after** §2.1's loop, and change its formula from
`unitProvX[matingUnitId] + minSep * 0.4` to `finalUnitX[matingUnitId] + minSep * 0.4` (same
constant offset, new base). Remove `duplicates$id` from `sweepIds`/`sweepGen` (`:889-891`) -- a
swept value is now unconditionally overwritten by this new formula, so sweeping it first is wasted
work, and D3 step 5's own language (*"not recursively laid out, contribute no width"*) already
signals duplicates were never meant to be a first-class sweep participant.

### 2.3 Broaden the final de-collision pass to include duplicate nodes

`R/makePedigreeDiagramData.R:936-954`'s `isDuplicate <- nodes$id %in% duplicates$id` /
`nonDupIdx <- which(!isDuplicate)` currently excludes duplicates from the epsilon-nudge
exact-coincidence guard. Since §2.2 removes duplicates from Track 3's own separation guarantee,
they need this pass's (already-existing, unmodified-in-mechanism) protection instead. Change to run
the same loop over **every** node (real, duplicate, and union) rather than excluding duplicates --
the mechanism itself (deterministic `(gen, id)`-ordered 1e-3 nudge) is unchanged, only the input
set widens by one category it already almost covers (union nodes are already included today).

### 2.4 Invariant this decision establishes

For every mating unit `U` with children `C`: `finalUnitX[U] == (min(x[C]) + max(x[C])) / 2`,
unconditionally, using each child's own final (post-sweep) `x`. This directly makes a union's
displayed position a deterministic function of its own immediate children, matching D1's own
sibship-bar span exactly -- the union's `dropId` point (`R/makePedigreeDiagramData.R:1500-1504`)
falls, by construction, at the midpoint of the very span D1 draws its bar across.

---

## 3. Rationale

Chosen over the alternatives in §4 on this project's own established design principle (restated
from Track 4's plan, §3): **a decision that structurally closes a defect class is preferred over
one that patches or signposts its current known instances, when the structural fix is validated and
its cost is bounded and measured, not speculative.**

- **Provably complete for the property it targets, and honestly incomplete for a different one.**
  Every union's `x` is, by construction, the center of its own children's span -- not empirically 0
  on one fixture, a deterministic consequence of the formula (§2.4). The 9 residual violations
  (§1.4) are not a gap in this proof; they are edges where the *children themselves* are far apart,
  a distinct, out-of-scope phenomenon (§8) this decision does not claim to fix -- named explicitly
  rather than left for a future session to rediscover the hard way, which is exactly the overclaim
  this document's own origin (S575's "no follow-up needed") was corrected for.
- **Reuses an existing, already-ratified formula rather than inventing a new one.** The
  midpoint-of-children's-merged-span computation is D3 step 2, unchanged -- this decision applies
  it a second time, to the FINAL (post-sweep) child positions, instead of only pre-sweep and then
  discarding the result. No new visual convention, no new positioning primitive.
- **Net simplification.** Deleting the anchor/non-anchor/orphan-unit branching in favor of one
  unconditional formula (§2.1) is fewer lines and fewer special cases, not more.
- **The duplicate-node side effect was caught and closed within this same design session, not
  deferred as a surprise for the implementation session.** §1.4 documents both the regression
  Candidate A alone would have introduced and the specific, measured fix (§2.2/§2.3) -- following
  this project's own precedent (Track 4 §3: *"the cost is real, measured, and disclosed -- not
  hidden"*).
- **Rejected: leave `dupX` in the Track 3 sweep, accept looser duplicate-to-union adjacency.**
  Measured worse (mean 849 vs. 48 scaled units) with no offsetting benefit -- the sweep's own
  minSep guarantee for `dupX` was already partially fictional (D3 step 5's own "not recursively
  laid out, contribute no width" language never intended duplicates to be a real sweep input; the
  current code including them is closer to incidental than intentional).
- **Rejected: Candidate B (propagate `sweepMinSep()`'s row-stretch factor to dependent rows).** The
  BACKLOG item's own alternate framing. Addresses only the sweep-driven **compounding** of the
  defect, not its root cause -- the decoupling exists even pre-sweep (a sparse, non-crowded fixture
  with a polygamous anchor would still show it). Requires new per-row stretch-factor bookkeeping
  with no existing precedent in this codebase, no clean provable-zero-gap invariant attainable (a
  proportional-scaling heuristic, not a structural guarantee), and unclear interaction with the
  free-pass-leaf/duplicate placement logic already in `positionUnit()`. Rejected in favor of a
  smaller, already-measured, invariant-establishing fix.
- **Rejected: threshold-based hybrid (child-centered only when the offset from the parent-midpoint
  exceeds some cutoff).** Arbitrary threshold, no principled way to choose it, introduces a
  discontinuity (small perturbations near the threshold flip which formula applies), and forfeits
  the clean §2.4 invariant this project's own recent precedent (Track 5) explicitly prefers over an
  empirically-bounded claim.
- **Rejected: give the anchor multiple positions, one per union (duplicate the anchor side too).**
  Would resolve the same defect class from the opposite direction, but breaks D1's ratified "anchor
  renders once" identity -- a bigger, more invasive change (more nodes, D6 click-to-navigate
  remapping, issue #138's node-count-cap accounting) for a project that already tracks node count
  against a scale ceiling. Strictly higher risk/cost than Candidate A for the same defect class,
  mirroring Track 4's own §3 rejection of an analogous "duplicate more things" alternative.
- **Rejected: replace the recursive contour-merge with a kinship2-parity linear/sibling-order
  algorithm.** Already explicitly rejected at the Option 2 layout design stage
  (`docs/planning/pedigree-diagram-option2-layout-design-plan.md`'s own "what is already decided"
  framing, §1.1 above) as disproportionate for this project's scale; re-litigating it here would be
  a from-scratch rewrite, not a bug fix, and is out of this document's own scope by definition
  (§1.1).

---

## 4. Alternatives Considered

| Alternative | Resolves the union-vs-children decoupling | Resolves the duplicate-vs-union side effect | Net code change | Residual | Status |
|---|---|---|---|---|---|
| **Extended Candidate A (adopted, §2)** | Yes -- structural invariant (§2.4), measured 91% reduction in >200-unit violations (100->9/251), 61% reduction in worst case (10,687->4,121) | Yes -- measured mean/max distance both 48 (tighter than baseline's 61.94/120.12) | Net simplification (§2.1 removes anchor/non-anchor/orphan branching); §2.2/§2.3 relocate ~10 lines | 9/251 edges (3.6%), all traced to sibling subtree-width asymmetry (§8, out of scope) | Adopted |
| A alone, no duplicate fix | Yes, same as above | **No -- regresses it** (measured mean 849, max 10,567) | Smaller diff than Extended A | Trades one defect for a related one | Rejected -- §1.4/§3 |
| B. Propagate `sweepMinSep()` row-stretch factor | Partial -- addresses only sweep-driven compounding, not the pre-sweep root cause | Not addressed | New per-row bookkeeping, no existing precedent | No clean zero-gap guarantee attainable; heuristic, not structural | Rejected -- §3 |
| C. Threshold-based hybrid (child-centered only past a cutoff) | Partial, cutoff-dependent | Not addressed without its own extension | Additive (branching + a new tunable constant) | Discontinuous; no principled threshold value; no clean invariant | Rejected -- §3 |
| D. Duplicate the anchor side too (multiple anchor positions per union) | Yes, in principle (opposite-direction fix) | N/A (changes what "duplicate" means) | Larger, more invasive -- breaks D1's "anchor renders once" identity, D6 remapping, node-count-cap impact | Unknown -- not built | Rejected -- higher risk/cost than A for the same defect class |
| E. Replace contour-merge with kinship2-parity linear algorithm | Yes, in principle | Yes, in principle (different algorithm entirely) | From-scratch rewrite | N/A | Rejected -- already excluded by §1.1, disproportionate for project scale |

---

## 5. Impact Analysis

| Surface | Impact | Action Required |
|---|---|---|
| `.positionMatingUnitForest()` `finalUnitX` computation (`:896-926`) | Replaced with §2.1's children-derived formula; anchor/non-anchor/orphan-unit branching removed | Full `test_positionMatingUnitForest.R` suite must be reviewed -- every hardcoded `x` expectation for a mating-unit node changes by design; re-derive from live implementation output, not hand-derive (matching Track 3/4's own established practice) |
| `dupX` computation (`:842-845`) | Relocated after §2.1's loop; formula changes base from `unitProvX` to the new `finalUnitX`; removed from `sweepIds`/`sweepGen` (`:889-891`) | Same test files -- every duplicate-node `x` expectation changes |
| Final de-collision pass (`:936-954`) | Broadened to include duplicate nodes (§2.3) | Existing coverage for real/union nodes unchanged; add a regression case exercising a duplicate-vs-real exact-coincidence, matching this session's own measured collision |
| D1 (sibship-bar waypoints, `.addRectilinearWaypoints()`) | Not modified -- reads whatever `x` the nodes carry. Benefits automatically: the `dropId` point (at the union's new, children-centered `x`) falls within or very near the bar's own span | `test_addRectilinearWaypoints.R` node/edge **structure** (ids, edge count, which edges get waypoints) is unaffected; any test asserting exact `x` coordinates on `__drop_`/`__bar_` nodes needs re-derivation |
| D2 (mate-line dogleg) | Not modified -- gated on `gen` equality only, never `x` (§1.1). Dogleg/direct-edge **length** changes (a polygamous anchor's mate edges to under-visited unions may lengthen), edge **count**/**structure** does not | Track 5's own orthogonality invariant re-verified by inspection (§1.1), not re-measured empirically (unnecessary -- proof by construction, this decision touches neither D1 nor D2's logic). A live render spot-check (§7) should still visually confirm mate-line edges read acceptably for the newly-longer cases |
| `edgeStyle = "direct"` / `edgeStyle = "rectilinear"` (default since Track 2, S574) | Both edge styles read the same underlying `x`/`y` positions from `.positionMatingUnitForest()`; this is a positioning fix, upstream of the `edgeStyle` branch entirely | Benefits both styles equally -- no `edgeStyle`-specific action needed |
| Track 3 (`sweepMinSep()`) | `dupX` removed from its input set (§2.2); real/duplicate-individual sweeping otherwise unchanged | Re-run `test_positionMatingUnitForest.R`'s own Track 3 regression tests to confirm the real/duplicate minSep guarantee (excluding duplicates from the *union-adjacency* concern, unaffected by this removal) still holds |
| Track 4 (gen-aware anchor selection) | Orthogonal -- Track 4 affects which unit an individual anchors and its `gen`, not `x` | None expected; re-run its own regression tests as part of full-suite verification |
| `makePedigreeMatingLayout()`'s node/edge counts (`test_makePedigreeMatingLayout.R`'s 714-node pin) | Unaffected -- this decision changes `x` values, not node/edge population | None -- but confirm via the full regression run rather than assume |
| Rendered visual character | A polygamous anchor's mate-line edges to their less-central unions become visibly longer (the "slack" moves from many child edges to few mate edges, §1.4/§3) | Live render spot-check (§7) of at least one real multi-anchor individual (Track 4's own `WCPXHD`, 5-way, is a ready-made real fixture example) before considering implementation done |
| The 9 residual sibling-subtree-width-asymmetry edges (§1.4, §8) | Not addressed by this decision | Filed as its own `BACKLOG.md` Housekeeping item this same session (§8); not folded into this decision's own completion criteria |

---

## 6. Migration Path (for the implementation session)

Single-commit change, matching #143/#144/Track 4's own precedent (small, synchronized, atomic):

1. **Edit `.positionMatingUnitForest()`**: implement §2.1 (replace the `finalUnitX` loop), §2.2
   (relocate and reformulate `dupX`, remove it from `sweepIds`/`sweepGen`), §2.3 (broaden the final
   de-collision pass). All three are one coordinated change to one function -- not separable
   sub-commits, since §2.2/§2.3 exist specifically to close the side effect §2.1 alone would
   introduce (§1.4).
2. **Re-derive every `x`-coordinate-dependent test expectation** in `test_positionMatingUnitForest.R`,
   `test_addRectilinearWaypoints.R` (for any test pinning exact `__drop_`/`__bar_`/`__proj_`
   coordinates), and `test_makePedigreeMatingLayout.R` from the fixed implementation's own live
   output -- matching Track 3/4's own established practice (empirically confirmed, not
   hand-derived).
3. **Add the new invariant test** (§2.4): for every mating unit on the real 375-individual fixture,
   `finalUnitX == (min(childX) + max(childX)) / 2`, 0 exceptions.
4. **Add a regression test for the duplicate-vs-real de-collision case** (§2.3) -- this session's
   own measurement found a real exact-coincidence on the bundled fixture; a synthetic minimal
   fixture reproducing the same shape (a duplicate node's post-formula `x` landing exactly on an
   unrelated same-gen real node) is preferable to depending on the full 375-individual fixture
   continuing to exhibit it after other changes land.
5. Rollback: pure computation, no persisted state or migration -- a plain `git revert` of the one
   commit.

This is scoped as its own implementation session (or, if the vertical-slice gates in
`SESSION_RUNNER.md` §Vertical Slice Sessions are satisfied against this document as the
pre-declared contract, potentially one session covering steps 1-4 as layers of one capability) --
not a multi-phase campaign.

---

## 7. Verification Plan (for the implementation session)

1. **RED**: write the new invariant test (§2.4, step 3 above) and the duplicate-de-collision
   regression test (step 4 above) against unmodified source; confirm both fail for the right
   reason (the invariant test against the current parent-midpoint formula; the de-collision test
   however it's constructed to reproduce the gap).
2. **GREEN**: implement §2.1-2.3 together in one commit.
3. **REFACTOR**: confirm rather than assume none is needed (matching #143/#144/Track 4's own
   precedent of checking, not skipping this phase by default).
4. **Re-measure, don't assume, this session's own headline figures** against the current codebase
   state at implementation time (3 commits may have landed since this design was written, per
   Track 4's own precedent for exactly this caveat): the 100/251->9/251 violating-edge counts, the
   10,687->4,121 max-offset figures, and the 849->48 duplicate-to-union distance figures are all
   this session's own fresh measurements (§1.4), not carried forward from an older session -- but
   confirm they still hold on whatever `HEAD` the implementation session starts from.
5. **Re-verify Track 5's own orthogonality invariant is unaffected** -- by inspection (D1/D2 code
   unchanged, §1.1), and empirically via the existing Track 5 measurement methodology as a
   confirmation, not a new investigation.
6. **Re-verify Track 3's minimum-separation guarantee** for real/duplicate individuals on the new
   node population (§5) -- expected to hold unmodified for reals; duplicates are no longer a Track
   3 sweep input (§2.2) by design, confirm the de-collision broadening (§2.3) is what protects them
   now, not a Track-3-shaped guarantee.
7. **Full regression suite + `devtools::check()`**: confirm every changed test traces to exactly
   this decision's own root cause (a stale hardcoded `x` value under the old formula), no unrelated
   files affected.
8. **Live verification (Phase 3E)**: render the real fixture under both `edgeStyle` values via
   `shinytest2`/`chromote`. Confirm (a) at least one real multi-anchor individual (e.g. Track 4's
   own `WCPXHD`, 5-way) renders with its unions visibly closer to their own children than before;
   (b) zero diagram-related console errors; (c) a visual spot-check of the lengthened mate-line
   edges (§5) reads acceptably, not just non-crashing; (d) the consanguineous-mating marker and
   duplicate dashed-arc convention (Claims 4c/7a) are unaffected -- this decision does not touch
   color/width/`smooth.type` logic.

**What DONE looks like**: the new invariant test (step 1) passes on the real fixture (0
exceptions); the duplicate-de-collision regression test passes; full suite + `devtools::check()` at
baseline elsewhere; live verification confirms the motivating scenario (a polygamous anchor's
unions now sitting near their own children) renders correctly and the owner has seen it rendered,
not just counted -- matching Track 4's own "the owner has seen the redistribution rendered"
completion bar, not just a numeric claim (the exact failure mode this document's own origin, S575,
was corrected for, §Origin above).

---

## 8. Explicitly Out of Scope (report, don't fix here -- `PROJECT_LEARNINGS.md` Learning 382)

- **Sibling subtree-width asymmetry** (§1.4) -- the 9 residual >200-unit edges on the real fixture,
  all cases where 2-3 direct children of one union have such different descendant-subtree sizes
  that they land far apart in `x` regardless of the union's own position. Not addressed by this
  decision, not reducible to a union-positioning question at all (it's a property of the sibling
  layout itself, one level down the same recursion). Filed as its own new `BACKLOG.md` Housekeeping
  item this same session (matching this project's own established practice of filing a discovered
  finding in the session that found it, not deferring the filing itself -- "report, don't fix
  mid-session" governs the *fix*, not the *filing*), citing this document's §1.4 for the concrete
  example (`__union_15`) and measured scope (9/251 edges, 3.6%, on the real fixture).
- **The duplicate-vs-nearby-real-node minSep guarantee remains partial, not absolute**, after §2.3
  -- the broadened de-collision pass catches *exact* coincidences (the same guarantee real/union
  nodes already have today) but not general crowding (a duplicate could still land visually close
  to, without exactly overlapping, an unrelated nearby node). This mirrors the project's existing,
  already-accepted risk posture for union nodes (never covered by Track 3's full minSep guarantee
  either) -- not a new standard being introduced, and not worth a heavier mechanism (e.g. folding
  duplicates back into Track 3's sweep with special-cased "then re-snap to the union" logic) without
  evidence it manifests as a real, visible problem beyond the one exact-coincidence case this
  session already found and closed.
- **7a (duplicate-connector arc curve direction)** -- the sibling BACKLOG item filed the same
  session as this one (S575). Unrelated surface (`smooth.type`/`smooth.roundness` on the dashed
  connector edge, not node positioning) -- explicitly a separate future session, not folded in here
  even though both trace to the same S575 post-close-out correction.
- **Re-deriving exact test-blast-radius figures** (how many existing hardcoded expectations break)
  -- not measured this session (this is a design document, not an implementation attempt); the
  implementation session's own full regression run is the authoritative count, per Track 4's own
  precedent for the same caveat.

---

## 9. Owner ratification record

- [x] **Proceed to implementation following this decision (Extended Candidate A, §2) as written**
- [ ] Proceed with modifications (specify which part to revisit)
- [ ] Hold -- more research needed before implementation begins

Ratified via `AskUserQuestion`, S576 (2026-08-14): presented 3 options (proceed as
written/recommended, proceed with modifications, hold for more research) with the measured
trade-offs stated directly in the question itself (91% violating-edge reduction, 61% worst-case
reduction, the 9 residual out-of-scope edges, the duplicate-to-union distance fix). Owner selected
"Proceed as written." No further modification requested; the decision is ratified as written in
§2.

---

## 10. Implementation Record (S578, 2026-08-14)

Implemented per §6 Migration Path, with 2 corrections found by Pre-RED empirical validation
(re-implementing the formula against unmodified `.buildMatingUnitForest()` output BEFORE
touching production code, per this session's own established discipline) that this document's
own §2.1 snippet and §5 Impact Analysis table did not state:

1. **Implementation-order correction.** §2.1's snippet shows `finalUnitX` computed in-place at
   its old pre-`orderBySex` location. Simulating that literally: the §2.4 invariant breaks for
   any union whose child is *also* swapped later as a parent in a deeper union (a common case --
   most individuals are both someone's child and someone's parent). Measured on the real
   fixture: 19/251 edges >200 units (not the ratified 9/251), max offset 9,112 (not 4,121).
   **Fix:** the `orderBySex` block itself was moved earlier in the function (was after the final
   de-collision pass; now right after the initial real-individual positions are established),
   and `finalUnitX`/`dupX` are computed after it. Same formula, same 3 coordinated changes (§2.1-
   §2.3) -- only their position in the existing pipeline moves. Re-measured with the reorder:
   9/251, max 4,121.37 (matches the ratified 4,121.25 to within the existing 1e-3 de-collision
   epsilon), duplicate-to-union distance 48.00/48.00 exact.
2. **Blast-radius correction.** §5 claims real-individual sweeping is "otherwise unchanged."
   Empirically false in one respect: removing duplicates from Track 3's sweep pool (§2.2)
   changes the sweep's own competition at a shared gen, which can shift a real individual's x
   non-trivially (not epsilon) when a duplicate previously occupied a competing slot -- measured
   on the small GA204Z/8LKBV9 fixture, `9VGCCV` shifts 2.25 -> 1.75 (0.5 units). This narrowed
   which existing tests needed re-derivation: `test_positionMatingUnitForest.R`'s "issue #143
   fix" exact-value block had 8 of 13 `expectPos()` calls change (not the 5 union/duplicate-only
   values the design doc's own framing implied), plus 2 further pre-existing tests the design
   doc did not anticipate (the "basic trio" test's own `unionX == (p1x+p2x)/2` assertion, which
   directly encoded the OLD parent-midpoint behavior; and the Track 3 minSep-guarantee test,
   narrowed to real individuals only now that duplicates share union nodes' existing "not a full
   minSep guarantee" posture, §8's own accepted-risk framing extended one category further).

**Verification (§7), re-measured at implementation time, not assumed from S576:**

- RED: 3 tests added/updated in `test_positionMatingUnitForest.R` (the §2.4 invariant on the
  small + real fixtures; the duplicate-vs-any-node exact-coincidence test; the "issue #143 fix"
  exact-value block) confirmed failing against unmodified source, for the right reasons
  (including a genuinely pre-existing duplicate/union coincidence, `__dup_LUPGF8_3` vs.
  `__union_191` at gen 4, unrelated to this decision but closed as a side effect of §2.3).
- GREEN: all 30 tests in `test_positionMatingUnitForest.R` pass (28 original/updated + the 2
  newly-discovered pre-existing tests fixed alongside them); `test_addRectilinearWaypoints.R`,
  `test_makePedigreeMatingLayout.R`, `test_buildMatingUnitForest.R` all pass unchanged (0
  hardcoded waypoint-coordinate or node-count assertions were affected, confirmed by grep before
  RED). Full clean regression: 1 pre-existing failure (`test_wordlist_coverage.R`), 0 new.
  `lintr::lint_package()`: 0 lints on both touched files.
- Live verification (§7 step 8): rendered + `chromote`-screenshotted the small GA204Z/8LKBV9
  fixture under both `edgeStyle` values -- visually confirmed `GA204Z` sits almost directly
  below its own parent union (matching `FJIB3R`'s x to within the 1e-3 de-collision epsilon),
  and the 8LKBV9xFJIB3R consanguineous duplicate dashed connector renders unaffected. Rendered +
  screenshotted the full real 375-individual fixture under both `edgeStyle` values: 0
  diagram-related console errors, layout visually sane at scale. (A quick WCPXHD-only subgraph
  attempt, built by truncating the real fixture to an 11-node neighborhood and recomputing
  `gen`, produced a visually crowded, misleading render -- an artifact of losing the real
  multi-generation context in that truncation, not a Track 6 defect; not used as evidence.)
- REFACTOR: gate offered; not needed beyond what GREEN already required (the reorder itself
  *is* the structural change §2 called for -- no separate cleanup pass identified).

**Files changed:** `R/makePedigreeDiagramData.R` (`.positionMatingUnitForest()`,
~line 833 onward -- single coordinated commit); `tests/testthat/test_positionMatingUnitForest.R`
(2 new tests, 3 updated tests).

---

## References

- `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §7b -- the origin of this
  design session and its own evidence base (reused, not re-derived).
- `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` -- the sibling design-session
  plan this document's own structure and rationale-framing follow most directly (same workstream,
  same "what is already decided" scoping discipline, same design/implementation session split).
- `docs/planning/pedigree-diagram-option2-layout-design-plan.md` §D3 -- the ratified recursive
  contour-merge algorithm this decision modifies one step of (step 4), not replaces.
- `PROJECT_LEARNINGS.md` Learning 581 -- the S575 post-close-out correction that surfaced this
  finding, and the practical rule ("state what a measurement is scoped to, don't let it read as a
  broader claim") this document's own §1.4/§8 scoping discipline directly applies.
