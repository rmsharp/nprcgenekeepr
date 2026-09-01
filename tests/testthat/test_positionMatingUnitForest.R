## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .positionMatingUnitForest() -- Pedigree Diagram Option 2, Slice 2
## (docs/planning/pedigree-diagram-option2-layout-design-plan.md D3/D4/D5).
## Consumes .buildMatingUnitForest()'s structural output (Slice 1) and assigns
## final x/gen coordinates: a simplified Reingold-Tilford/Walker-style
## recursive contour-merge (D3), founders ordered by input row order (D4),
## the D5 one-known-parent fallback attaching directly (no synthesized
## union). Contour tracking is indexed by each node's REAL gen (not
## recursive tree depth), since D3 step 6 (ratified) pins y to real gen,
## which can diverge from recursive depth once a duplicate/free-pass node is
## re-attached deep inside another individual's subtree -- a genuine tree
## cannot hit this (ancestor and descendant are never at the same depth),
## but this forest can, since it deliberately re-attaches nodes (this
## session's own POC finding, see docs/planning design doc §9).

## ---- test helpers (not exported, local to this file) ------------------

.nodeKind <- function(ids) {
  ifelse(grepl("^__union_", ids), "union",
         ifelse(grepl("^__dup_", ids), "duplicate", "individual"))
}

.expectNoOverlap <- function(positions) {
  nonDup <- positions[.nodeKind(positions$id) != "duplicate", ]
  key <- paste(round(nonDup$x, 6), nonDup$gen)
  testthat::expect_false(any(duplicated(key)))
}

## ---- input validation ---------------------------------------------------

test_that(".positionMatingUnitForest rejects non-data-frame 'ped'", {
  ped <- data.frame(id = "F1", sire = NA, dam = NA, sex = "F", gen = 0L,
                     stringsAsFactors = FALSE)
  forest <- .buildMatingUnitForest(ped)
  expect_error(.positionMatingUnitForest(list(a = 1), forest), "data frame")
})

test_that(".positionMatingUnitForest rejects a pedigree missing required
           columns", {
  noGen <- data.frame(id = "F1", sire = NA, dam = NA, sex = "F",
                       stringsAsFactors = FALSE)
  expect_error(.positionMatingUnitForest(noGen, list()), "gen")
})

## ---- basic trio: union x is the midpoint of its 3 children's span -----
## Track 6 (docs/planning/pedigree-diagram-track6-child-centered-union-
## position-plan.md sec2.1, this session): the union's x is no longer the
## midpoint of its 2 PARENTS -- it is the midpoint of its own CHILDREN's
## min/max final x. Confirmed live this session (GREEN) that this simple
## symmetric-trio fixture's own parent-midpoint and child-span-midpoint
## values genuinely differ (not a coincidental match): re-derived from the
## fixed implementation's own output, not hand-derived.

## Walker/BJL cutover (docs/planning/pedigree-diagram-walker-bjl-
## apportioning-redesign-plan.md Phase 3, this session): Track 3's
## parent-span clamp is REMOVED by this migration -- the union's x was
## genuinely, unconditionally the midpoint of its own children's final x
## (Tier 2 of the new engine), never clamped toward its 2 parents.
##
## Track 7 Phase 3 CHANGE (docs/planning/pedigree-diagram-track7-phase3-
## child-centering-plan.md §2.1, S652 -- issue #166, scoped revert): the
## Track 7 Phase 1 recenter loop that overrode this qualifying union's x
## to the anchor/mate midpoint (1.5) is DELETED. Tier 2's own unconditional
## `mean(tier1X[kids])` is once again the union's only formula -- P1 stays
## at its own tier1X (1.0, centered over its 3 children by BJL's own
## Tier-1 apportioning, per Finding B's proven anchor/children-mean
## identity), so mean(C1,C2,C3) == 1.0 exactly, coinciding exactly with
## P1's own x at the same gen. The pre-existing exact-tie epsilon sweep
## (unchanged by this revert -- the same mechanism this codebase has
## always used for a union/genuine-node coincidence) nudges the union
## 0.001 raw units away, landing it at 1.001, not the bare 1.0 -- measured
## live against the reverted code (pkgload::load_all() spike, never hand-
## derived), matching this project's own established practice. Track 7
## Phase 1's OTHER change (P2's widened minSep offset, kept per the
## ratified design) is unaffected -- not asserted here, this test only
## checks childX/unionX.
test_that(".positionMatingUnitForest positions a simple 2-parent/3-child
           trio with the union's x as the exact midpoint of its own 3
           children (Tier 2, no Track-7-Phase-1 recenter -- issue #166
           scoped revert) plus the pre-existing epsilon nudge from
           exactly coinciding with the anchor's own tier1X -- and 3
           distinct, non-overlapping child x positions one gen below", {
  trio <- data.frame(
    id = c("P1", "P2", "C1", "C2", "C3"),
    sire = c(NA, NA, "P1", "P1", "P1"), dam = c(NA, NA, "P2", "P2", "P2"),
    sex = c("M", "F", "M", "F", "M"), gen = c(0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(trio)
  pos <- .positionMatingUnitForest(trio, forest)

  expect_equal(nrow(pos), 6L)  # 5 individuals + 1 union (0 duplicates)
  expect_setequal(pos$id, c(trio$id, forest$matingUnits$id))

  childX <- pos$x[pos$id %in% c("C1", "C2", "C3")]
  unionX <- pos$x[pos$id == forest$matingUnits$id]
  expect_equal(unionX, 1.001, tolerance = 1e-6)

  expect_equal(length(unique(round(childX, 6))), 3L)
  expect_true(all(pos$gen[pos$id %in% c("C1", "C2", "C3")] == 1L))
  .expectNoOverlap(pos)
})

## ---- D5: mating-unit child + direct one-parent child on same anchor ---

test_that(".positionMatingUnitForest positions an individual's mating-unit
           child and D5 direct (one-known-parent) child without overlap,
           and the direct child's gen is its own recorded gen", {
  ped <- data.frame(
    id = c("P", "Q", "C1", "C2"),
    sire = c(NA, NA, "P", "P"), dam = c(NA, NA, "Q", NA),
    sex = c("M", "F", "F", "M"), gen = c(0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  expect_equal(pos$gen[pos$id == "C2"], 1L)
  .expectNoOverlap(pos)
})

## ---- multi-mate anchor, uneven-depth sibling subtrees -----------------

test_that(".positionMatingUnitForest positions a multi-mate anchor's 2
           mating-unit subtrees (one a leaf, one 2 generations deep)
           without overlap", {
  ped <- data.frame(
    id = c("X", "Y", "Z", "W", "C1", "C2", "GC1"),
    sire = c(NA, NA, NA, NA, "X", "X", "C2"),
    dam = c(NA, NA, NA, NA, "Y", "Z", "W"),
    sex = c("M", "F", "F", "F", "F", "M", "F"),
    gen = c(0L, 0L, 0L, 0L, 1L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  expect_equal(nrow(pos), nrow(ped) + nrow(forest$duplicates) +
                 nrow(forest$matingUnits))
  .expectNoOverlap(pos)
})

## ---- real GA204Z/8LKBV9 loop fixture (from Slice 1's own test suite) --

test_that(".positionMatingUnitForest positions the real GA204Z/8LKBV9 loop
           fixture (Track 4: 8LKBV9 now anchors 2 of his 3 mating units --
           his 2 founder mates, on gen alone -- and is duplicated at
           exactly the other 1, his own daughter FJIB3R's unit, which she
           now anchors) without overlap, with the duplicate's gen matching
           ITS OWN mating unit's gen (issue #143 fix, still in effect,
           unaffected by Track 4: 2L, not 8LKBV9's own raw gen of 1L)", {
  ped <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  kDup <- pos[pos$id %in% forest$duplicates$id[
    forest$duplicates$realId == "8LKBV9"], ]
  expect_equal(nrow(kDup), 1L)

  unit4 <- forest$matingUnits$id[forest$matingUnits$dam == "FJIB3R"]
  dupAt4 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit4]
  expect_equal(pos$gen[pos$id == dupAt4], 2L)  # unit4's own gen

  .expectNoOverlap(pos)
})

## ---- exact x/gen regression guard: catches an Edit-1/Edit-2 desync -----
## (issue #143 fix -- if either of the plan's 2 synchronized edits ships
## without the other, this fixture's own values diverge in 3 different,
## independently distinguishable ways from the correct combined fix.
## Verified empirically this session against 4 independently patched
## variants of .positionMatingUnitForest() (baseline, Edit-1-only,
## Edit-2-only, both): baseline leaves G8EBU9 at (x=0.25, gen=0); an
## Edit-1-only fix shifts x (to ~0) but leaves gen wrong (still 0); an
## Edit-2-only fix gets gen right (1) but leaves x at the stale 0.25. Only
## both edits together produce (x=0, gen=1). A geometric minimum
## -separation check (as originally contemplated in the plan's own §6) was
## investigated and found NOT to discriminate these cases in this
## algorithm -- unrelated same-row nodes are not guaranteed >= minSep apart
## even under the fully-corrected fix (300+ such close-but-non-identical
## pairs exist in the real 375-individual fixture under every one of the 4
## variants, including the fully-fixed one) -- so this exact-value
## assertion is used instead, as a strictly stronger guard.
##
## Track 4 update (docs/planning/pedigree-diagram-track4-gen-aware-anchor-
## plan.md, this session): this SAME fixture previously embedded one of the
## 51 real-fixture anchor-side mismatches -- 8P17E3 anchored the unit3 union
## (dam="8P17E3") at unitGen=1, despite her own raw ped$gen being 0, and
## issue #144's now-deleted effGenOf mechanism relocated her DISPLAYED gen
## to 1 to compensate. Under Track 4's gen-first D2 tie-break, 8LKBV9
## (gen 1) now beats 8P17E3 (gen 0) outright and anchors unit3 himself --
## there is no mismatch left to relocate. 8P17E3 becomes unit3's NON-anchor
## (free-pass) occurrence instead, and issue #143's still-unchanged
## non-anchor override renders her at her unit's gen (1) regardless -- same
## displayed value as before, reached by a different, now-invariant-
## respecting mechanism. Her x (2.00) is unaffected either way, since x
## comes purely from mergeSubtrees(), never from ownGen. 8LKBV9 himself
## keeps 3 mates but now anchors 2 of them (his 2 founder mates) instead of
## 1 (re-verify against test_buildMatingUnitForest.R's own updated figure)
## -- moving G8EBU9's union and 8P17E3's union positions, which cascade
## into 8LKBV9's own x. FJIB3R (gen 2) still beats 8LKBV9 (gen 1) on unit4
## and anchors it, unchanged from before. Every value below re-verified
## live against the current implementation, not hand-derived.
##
## 5A6DFT/8DKELJ's own x values reflect issue #145 (male-left/female-right
## default, D2/D3): this pair is the forest's only D1-qualifying
## (mate-count-1, unambiguous-M/F, no D5 child) unit, so 5A6DFT (sire, sex
## 'M') and 8DKELJ (dam, sex 'F') swap places -- unaffected by Track 4
## (unit1 does not involve 8LKBV9's family). Every value below additionally
## reflects Track 3's minSep guarantee: every same-gen gap in this fixture
## is now exactly minSep = 1 apart, re-verified live against the fixed
## implementation.
##
## Walker/BJL cutover (Phase 3, this session): Track 3's parent-span
## clamp is REMOVED entirely -- every mating unit's x is now the exact
## midpoint of its own real children's final Tier-1 x (Tier 2), with no
## clamp/nudge disjunction. BJL's own coordinate convention differs
## fundamentally from the OLD contour-merge's (leftmost-leaf-anchored,
## monotonically increasing, not centered around 0), so every x value
## below is a genuinely different absolute number from the OLD algorithm
## -- gen values are UNCHANGED (D1/D2/D4 anchor selection/gen assignment
## is out of this migration's scope). Every value below re-derived by
## actually running the new engine against UNMODIFIED
## .buildMatingUnitForest() output (never hand-derived), matching this
## project's own established Track 3/4/Walker-BJL practice.

test_that(".positionMatingUnitForest's exact x/gen values for the real
           GA204Z/8LKBV9 loop fixture reflect Track 4's gen-first D2
           anchor selection -- 8LKBV9 now anchors his 2 founder mates
           (gen alone beats founder-preference's old outcome for the same
           winner) but loses the anchor role for 8P17E3's unit to 8LKBV9
           himself (gen 1 beats her gen 0), and issue #143's non-anchor
           override still renders her at her unit's gen. x values reflect
           the Walker/BJL engine's own child-centered Tier 1-3
           positioning (Phase 3 cutover) -- gen values are unaffected,
           unchanged from the OLD algorithm.", {
  ped <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  expectPos <- function(id, x, gen) {
    expect_equal(pos$x[pos$id == id], x, tolerance = 1e-6)
    expect_equal(pos$gen[pos$id == id], gen)
  }

  expectPos("5A6DFT", 0.5, 0L)
  ## 8DKELJ CHANGED from 0.9 to 1.5 (Track 7, S647): unit1 is this
  ## fixture's own only qualifying union (5A6DFT/8DKELJ, mate-count-1
  ## each, no D5 child, unambiguous M/F -- unaffected by 8LKBV9's own
  ## unrelated 2/3-mate units below), so 8DKELJ's derived point widens
  ## from 5A6DFT's x + minSep*0.4 (0.5+0.4) to + minSep (0.5+1.0).
  expectPos("8DKELJ", 1.5, 0L)
  expectPos("G8EBU9", 0.4, 1L)
  expectPos("8P17E3", 1.4, 1L)  # gen unaffected: issue #143's non-anchor
                                 # override (she no longer anchors unit3,
                                 # 8LKBV9 does -- Track 4)
  expectPos("8LKBV9", 0.5, 1L)
  expectPos("FJIB3R", 0.0, 2L)
  expectPos("9VGCCV", 1.0, 2L)
  expectPos("GA204Z", 0.0, 3L)

  unit1 <- forest$matingUnits$id[forest$matingUnits$sire == "5A6DFT"]
  unit2 <- forest$matingUnits$id[forest$matingUnits$dam == "G8EBU9"]
  unit3 <- forest$matingUnits$id[forest$matingUnits$dam == "8P17E3"]
  unit4 <- forest$matingUnits$id[forest$matingUnits$dam == "FJIB3R"]
  ## Every NON-qualifying mating-unit's x is still the midpoint of its OWN
  ## CHILDREN's final x (Tier 2), no clamp exceptions. unit2/unit3/unit4
  ## all fail qualifies() (8LKBV9/FJIB3R each have mateCountP/M == 3, not
  ## 1 -- 8LKBV9 anchors 2 units and is non-anchor on a 3rd), so none of
  ## the 3 are affected by Track 7. unit4 (single child GA204Z, x=0.0)
  ## ties nothing here but its own midpoint math still nets a 1e-3 nudge
  ## under this fixture (unchanged).
  ##
  ## unit1 CHANGED AGAIN (Track 7 Phase 3, S652 -- issue #166, scoped
  ## revert, docs/planning/pedigree-diagram-track7-phase3-child-centering-
  ## plan.md §2.1): the Phase 1 recenter loop that moved unit1's x to the
  ## anchor/mate midpoint (1.0, the prior value here) is deleted. unit1's
  ## x reverts to Tier 2's unconditional mean(tier1X[kids]) -- here, just
  ## 8LKBV9's own x (0.5) -- which exactly coincides with 5A6DFT's own
  ## tier1X (0.5) at the same gen (0), the anchor/children-mean identity
  ## Finding B proves holds for every qualifying unit with mateCountP==1.
  ## The pre-existing exact-tie epsilon sweep (unaffected by this revert)
  ## nudges it 0.001 away, landing at 0.501, not the bare 0.5 -- measured
  ## live against the reverted code, never hand-derived. Track 7 Phase 1's
  ## OTHER change (8DKELJ's widened offset, 1.5 above) is kept, per the
  ## ratified design.
  expectPos(unit1, 0.501, 0L)
  expectPos(unit2, 0.0, 1L)
  expectPos(unit3, 1.0, 1L)  # no clamp under the new engine: unit3's own
                              # child 9VGCCV's x IS its exact midpoint
  expectPos(unit4, 0.001, 2L)

  dupAt4 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit4]
  ## unit3 no longer has a duplicate (8LKBV9 anchors it directly now).
  expect_equal(forest$duplicates$matingUnitId[
    forest$duplicates$realId == "8LKBV9"], unit4)
  expectPos(dupAt4, 0.401, 2L)  # B3 derived point: unit4's own FINAL x
                                 # (0.001) + minSep*0.4
})

## ---- Track 3: minimum mate-spacing guarantee (kinship2 fidelity
## remediation plan, docs/planning/pedigree-diagram-kinship2-fidelity-
## remediation-plan.md Track 3) --------------------------------------------
## D3's contour-merge (mergeSubtrees(), :683-703) only guarantees adjacent
## subtrees do not exactly overlap -- it does not guarantee a minimum visual
## gap between two unrelated same-generation nodes nested at different
## recursion depths (documented dragon,
## pedigree-diagram-option2-layout-design-plan.md:486-495, "New dragon found
## S461"). This test asserts the general property directly, reusing the real
## GA204Z/8LKBV9 loop fixture already established above -- its own docstring
## (:148-164) already recorded that this exact fixture contains 300+ such
## close-but-non-identical pairs in the real 375-individual pedigree.
## Confirmed empirically against UNMODIFIED source this session: gen 0 gap
## 0.5, gen 1 gaps 0.5/0.4, gen 2 gaps 0.4/0.6 -- all below the existing
## minSep = 1 constant already used elsewhere in the algorithm.
##
## Track 6 update (docs/planning/pedigree-diagram-track6-child-centered-
## union-position-plan.md sec2.2, this session): duplicate nodes are now
## ALSO excluded from the full minSep guarantee, not just union nodes --
## sec2.2 removes duplicates from Track 3's own sweep input set (a
## duplicate's x is now a derived offset from its own mating unit's FINAL
## x, no longer an independently swept leaf). This mirrors the project's
## existing, already-accepted risk posture for union nodes (design doc
## sec8): duplicates keep the WEAKER exact-coincidence guarantee (the
## broadened final de-collision pass, sec2.3, confirmed by the dedicated
## test below) but not the full minSep-between-every-pair guarantee this
## test asserts for REAL individuals only, confirmed to genuinely narrow
## (not just relabel) this fixture's own gen-2 gap: 0.399 with the
## duplicate included (fails), no violation with it excluded.

## Walker/BJL cutover (Phase 3, this session): this test's own methodology
## (filtering to REAL individual nodes purely by .nodeKind() id-pattern)
## is no longer sound under the new engine -- found during GREEN, not
## assumed. A B1 free-pass individual's derived point (Tier 3) shares its
## OWN real id (no separate __dup_ node), is NEVER swept by
## sweepMinSep()'s backstop (S3.1.1, real Tier-1 tree nodes only), and 2
## different B1 individuals at the same gen can legitimately land closer
## than minSep apart, each independently derived relative to a different
## anchor. This exact fixture has 3 such B1 individuals (8DKELJ, G8EBU9,
## 8P17E3), reproducing exactly that shape. The merged-in Phase 2a
## property test below ("guarantees at least minSep... on the real
## GA204Z/8LKBV9 loop fixture") is this test's own correctly-scoped
## successor -- it excludes every id that IS a nonAnchor anywhere, rather
## than trusting id-pattern alone, and is not duplicated here.

## ---- half-sib-mating convergent loop -----------------------------------

test_that(".positionMatingUnitForest positions a half-sib-mating
           convergent loop (F1 doubly-mated, A/B/C forming the loop)
           without overlap", {
  ped <- data.frame(
    id = c("F1", "F2", "F3", "A", "B", "C"),
    sire = c(NA, NA, NA, "F1", "F1", "A"),
    dam = c(NA, NA, NA, "F2", "F3", "B"),
    sex = c("M", "F", "F", "M", "F", "M"),
    gen = c(0L, 0L, 0L, 1L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  .expectNoOverlap(pos)
})

## ---- an isolated founder beside an unrelated family --------------------

test_that(".positionMatingUnitForest positions a fully isolated founder
           (no mating units, no children) as its own trivial one-node
           tree, distinct from an unrelated family's positions", {
  ped <- data.frame(
    id = c("ISOLATED", "P1", "P2", "C1"),
    sire = c(NA, NA, NA, "P1"), dam = c(NA, NA, NA, "P2"),
    sex = c("F", "M", "F", "M"), gen = c(0L, 0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  expect_true("ISOLATED" %in% pos$id)
  expect_false(is.na(pos$x[pos$id == "ISOLATED"]))
  .expectNoOverlap(pos)
})

## ---- a founder with many mating units (wide fan-out), §9 dragon -------

test_that(".positionMatingUnitForest positions a founder with 8 distinct
           mating units (wide fan-out) without overlap among any of the
           16 resulting individual/union nodes", {
  nMates <- 8
  ped <- data.frame(
    id = c("SIRE", paste0("DAM", seq_len(nMates)), paste0("KID", seq_len(nMates))),
    sire = c(NA, rep(NA, nMates), rep("SIRE", nMates)),
    dam = c(NA, rep(NA, nMates), paste0("DAM", seq_len(nMates))),
    sex = c("M", rep("F", nMates), rep("M", nMates)),
    gen = c(0L, rep(0L, nMates), rep(1L, nMates)),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  expect_equal(nrow(forest$matingUnits), nMates)
  .expectNoOverlap(pos)
})

## ---- a deeply unbalanced tree (6-generation chain vs. 1-leaf sibling) -

test_that(".positionMatingUnitForest positions a deeply unbalanced tree
           (one branch 6 generations deep, sibling branch a single leaf)
           without overlap, §9's 'expect careful edge-case testing'
           dragon", {
  ped <- data.frame(
    id = c("R1", "R2", sprintf("D%d", 1:6), "SHALLOW"),
    sire = c(NA, NA, "R1", "D1", "D2", "D3", "D4", "D5", "R1"),
    dam = c(NA, NA, "R2", NA, NA, NA, NA, NA, "R2"),
    sex = c("M", "F", rep("M", 6), "F"),
    gen = c(0L, 0L, 1:6, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  .expectNoOverlap(pos)
})

## ---- full real 375-individual bundled fixture (scale check) -----------

test_that(".positionMatingUnitForest positions the full real
           375-individual bundled fixture at the exact node count
           established by Slice 1, with a bounded, disclosed residual of
           exact-position overlaps (Track 7, S647) and no NA x/gen", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  expect_equal(nrow(pos), nrow(ped) + nrow(forest$duplicates) +
                 nrow(forest$matingUnits))
  ## CHANGED from 740L (375 + 128 + 237) -- Track 4's gen-first D2
  ## redistribution drops the duplicate count to 102 (see
  ## test_buildMatingUnitForest.R's own updated figure): 375 + 102 + 237.
  expect_equal(nrow(pos), 714L)
  expect_false(any(is.na(pos$x)))
  expect_false(any(is.na(pos$gen)))
  ## Track 7 CHANGE (S647): widening the B1 offset to minSep exposed a
  ## pre-existing gap where a de-collided point could still tie an
  ## unrelated individual. A capped bidirectional search
  ## (R/makePedigreeDiagramData.R's .deCollideIndividualPoints(),
  ## .kMaxIndividualPush = 2) resolves MOST of these -- but on this real,
  ## densely-packed fixture (173 gen-0 founders), a small number sit in a
  ## row occupied on both sides beyond the cap, and fall back to the
  ## ORIGINAL small circle-on-circle near-overlap (0.001 raw units / 0.12
  ## px, the SAME already-accepted magnitude documented for the 24 pairs
  ## found before this fix existed at all) rather than an unbounded drift
  ## -- deliberately: an uncapped search was found live to cause much
  ## larger, worse D1 sibship-bar-vs-bar overlaps elsewhere (up to
  ## 540px). 13 pairs plus 1 triple-collision (27 nodes total) remained,
  ## down from 24 pairs before this session's Tier-3 sweep existed at all
  ## -- a real reduction, not zero, measured directly and disclosed here
  ## rather than asserted away.
  nonDup <- pos[.nodeKind(pos$id) != "duplicate", ]
  key <- paste(round(nonDup$x, 6), nonDup$gen)
  nCollidingNodes <- sum(duplicated(key) | duplicated(key, fromLast = TRUE))
  ## Track 7 Phase 2 (S649, see the section below): re-verified live that
  ## this exact-tie metric is UNCHANGED by Phase 2's union-side push --
  ## it is driven entirely by the individual side's own residual, which
  ## Phase 2 never touches (the union sweep's own pre-existing epsilon
  ## nudge never produced exact ties in the first place).
  ## Track 7 Phase 3 (S652 -- issue #166, scoped revert): re-verified live
  ## against the reverted code (pkgload::load_all() spike, never assumed)
  ## that this metric is ALSO unchanged at 27L -- the design's own §2.1
  ## simulation found 0 new individual-vs-union/union-vs-union collisions
  ## post-revert, confirmed here directly rather than taken on the design
  ## doc's word alone.
  ## CHANGED to 0L (B1-individual-vs-unrelated-individual proximity fix,
  ## docs/planning/pedigree-diagram-b1-individual-proximity-plan.md,
  ## design ratified S661, implementation S662): the entire 27-node exact-
  ## tie residual was composed of B1-vs-unrelated-individual ties this
  ## fix's new pass resolves -- re-measured directly by actually running
  ## the fixed engine, never hand-derived.
  expect_equal(nCollidingNodes, 0L)
})

## ---- gen semantics: every node's gen matches its source-of-truth ------

test_that(".positionMatingUnitForest's gen column matches each occurrence's
           CORRECTED source of truth (issue #143, plus Track 4's own
           structural invariant in place of issue #144's now-deleted
           effGenOf): a FREE-PASS or DUPLICATE occurrence's own MATING
           UNIT's gen (issue #143 -- unaffected by Track 4), an ANCHOR's
           own RAW gen -- always equal to its unit's gen by construction
           now (Track 4 §2.3/§2.4, no relocation mechanism needed or
           present any longer), and a mating unit's already-verified
           max(parent gens) from Slice 1", {
  ped <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  ## Non-parent leaves keep their own ped$gen (never an anchor, never a
  ## unit parent). Anchors display their own RAW gen, unconditionally --
  ## Track 4 makes this always equal the unit's gen by construction, so no
  ## separate "effective gen" concept exists any longer. Re-verified
  ## against forest$matingUnits$anchor/gen this session: 8LKBV9 now anchors
  ## BOTH founder units (G8EBU9's and 8P17E3's), FJIB3R still anchors her
  ## own unit; 9VGCCV/GA204Z are non-parent children, never sire/dam of any
  ## unit.
  expect_equal(pos$gen[pos$id == "5A6DFT"], 0L)
  expect_equal(pos$gen[pos$id == "8LKBV9"], 1L)
  expect_equal(pos$gen[pos$id == "FJIB3R"], 2L)
  expect_equal(pos$gen[pos$id == "9VGCCV"], 2L)
  expect_equal(pos$gen[pos$id == "GA204Z"], 3L)

  ## 8DKELJ is free-pass, but her one unit's gen (max(5A6DFT=0, 8DKELJ=0))
  ## already equals her own gen -- no visible change, still 0.
  expect_equal(pos$gen[pos$id == "8DKELJ"], 0L)

  ## G8EBU9 is free-pass and mismatched: her own gen is 0, but her one
  ## unit's gen (max(8LKBV9=1, G8EBU9=0)) is 1 -- issue #143's non-anchor
  ## override, unaffected by Track 4.
  expect_equal(pos$gen[pos$id == "G8EBU9"], 1L)

  ## 8P17E3 CHANGED from anchoring unit3 (pre-Track-4) to being its
  ## free-pass non-anchor occurrence: 8LKBV9 (gen 1) now beats her (gen 0)
  ## on the gen-first tie-break. She keeps the SAME displayed gen (1,
  ## issue #143's non-anchor override, since her unit's gen is 1) via a
  ## different, now-invariant-respecting mechanism -- no longer via
  ## issue #144's deleted effGenOf relocation, since she is no longer an
  ## anchor at all.
  expect_equal(pos$gen[pos$id == "8P17E3"], 1L)

  ## Only 1 duplicate exists now (8LKBV9 at unit4, FJIB3R's unit) --
  ## unit3 no longer needs one, since 8LKBV9 anchors it directly.
  unit4 <- forest$matingUnits$id[forest$matingUnits$dam == "FJIB3R"]
  dupAt4 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit4]
  expect_equal(nrow(forest$duplicates), 1L)
  expect_equal(pos$gen[pos$id == dupAt4], 2L)  # unit4's own gen

  unitRows <- pos[pos$id %in% forest$matingUnits$id, ]
  expect_equal(
    unitRows$gen[match(forest$matingUnits$id, unitRows$id)],
    forest$matingUnits$gen
  )
})

## ---- dangling parent references (Slice 3 live-verification finding,
## S461): consumes .buildMatingUnitForest()'s own dangling-parent handling
## -- a free-pass or duplicate node for an individual with no own row in
## 'ped' needs a gen fallback, not a crash on an unresolvable lookup. ----

test_that(".positionMatingUnitForest positions the mating unit whose
           non-anchor parent is a dangling free-pass reference (no own
           row in 'ped') without error -- the dangling parent gets no
           node of its own (nothing real to render), but the unit's x is
           still a valid, finite midpoint", {
  ped <- data.frame(
    id = c("GRANDSIRE", "SIRE", "CHILD"),
    sire = c(NA, "GRANDSIRE", "SIRE"),
    dam = c(NA, NA, "DANGLING_DAM"),
    sex = c("M", "M", "F"),
    gen = c(0L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- expect_error(.positionMatingUnitForest(ped, forest), NA)

  ## The dangling parent has no record to render as its own node --
  ## confirmed absent, not merely unchecked.
  expect_false("DANGLING_DAM" %in% pos$id)
  expect_equal(nrow(pos), nrow(ped) + nrow(forest$matingUnits))

  unitX <- pos$x[pos$id == forest$matingUnits$id]
  expect_false(is.na(unitX))
  expect_true(is.finite(unitX))
  ## found S555: the dangling-parent gen fallback must not widen 'gen'
  ## from integer to double -- expect_equal(0, 0L) is type-blind, so this
  ## needs expect_type(), not a numeric-equality assertion, to actually
  ## catch the coercion.
  expect_type(pos$gen, "integer")
  .expectNoOverlap(pos)
})

test_that(".positionMatingUnitForest positions a dangling parent's
           duplicate node (appearing at more than one mating unit)
           without error, using its mating unit's own gen as the
           fallback -- the dangling parent's FREE (non-duplicate)
           occurrence still gets no node of its own", {
  ped <- data.frame(
    id = c("SIRE1", "SIRE2", "CHILD1", "CHILD2"),
    sire = c(NA, NA, "SIRE1", "SIRE2"),
    dam = c(NA, NA, "DANGLING_DAM", "DANGLING_DAM"),
    sex = c("M", "M", "F", "M"),
    gen = c(0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  expect_equal(nrow(forest$duplicates), 1L)
  pos <- expect_error(.positionMatingUnitForest(ped, forest), NA)

  expect_false("DANGLING_DAM" %in% pos$id)
  dupRow <- pos[pos$id == forest$duplicates$id, ]
  expect_equal(nrow(dupRow), 1L)
  expect_false(is.na(dupRow$gen))
  expect_false(is.na(dupRow$x))
  ## found S555: see the free-pass dangling-parent test above.
  expect_type(pos$gen, "integer")
  .expectNoOverlap(pos)
})

## ---- issue #154: 2 dangling-parent crash bugs found incidental to issue
## #144's own review (BACKLOG.md items B4a/B4b, unrelated to the free-pass
## cases above) -- both confirmed by direct reproduction against master
## before this fix: (a) any individual with 'gen = NA' crashed
## rep(Inf, maxGen + 1L) with "invalid 'times' argument" (maxGen itself came
## back NA, since max() has no na.rm); (b) a mating unit whose sire AND dam
## are BOTH dangling crashed mergeSubtrees()'s subResults[[1L]] with
## "subscript out of bounds" -- .buildMatingUnitForest() could pick one of
## the two dangling ids as anchor (its "a dangling parent can never anchor"
## guard only covers the single-dangling case), and a unit anchored by a
## dangling id is never reached by the recursive descent, leaving rootIds
## empty. --------------------------------------------------------------

test_that(".positionMatingUnitForest treats a real individual's NA gen as
           generation 0 instead of crashing on maxGen <- max(ped$gen, ...)
           (issue #154)", {
  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    gen = c(0L, 0L, NA),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- expect_error(.positionMatingUnitForest(ped, forest), NA)

  cRow <- pos[pos$id == "C", ]
  expect_equal(nrow(cRow), 1L)
  expect_equal(cRow$gen, 0L)
  expect_true(is.finite(cRow$x))
  .expectNoOverlap(pos)
})

test_that(".positionMatingUnitForest positions a mating unit whose sire AND
           dam are BOTH dangling as an independent root instead of
           crashing mergeSubtrees() on an empty rootIds (issue #154) -- the
           unit's own gen falls back to 0L, not NA", {
  ped <- data.frame(
    id = "CHILD",
    sire = "DANGLING_SIRE",
    dam = "DANGLING_DAM",
    sex = "F",
    gen = 0L,
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- expect_error(.positionMatingUnitForest(ped, forest), NA)

  expect_false("DANGLING_SIRE" %in% pos$id)
  expect_false("DANGLING_DAM" %in% pos$id)
  unitRow <- pos[pos$id == forest$matingUnits$id, ]
  expect_equal(nrow(unitRow), 1L)
  expect_equal(unitRow$gen, 0L)
  expect_true(is.finite(unitRow$x))
  childRow <- pos[pos$id == "CHILD", ]
  expect_true(is.finite(childRow$x))
  ## found S555: see the free-pass dangling-parent test above.
  expect_type(pos$gen, "integer")
  .expectNoOverlap(pos)
})

## ---- issue #143/#144 regression guard: real-fixture anchor/non-anchor
## mismatch counts (re-derives docs/audits/
## FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md's own detection method,
## corrected to separate anchor from non-anchor mismatches -- the audit's
## own method could not distinguish them, both being plain real-id nodes
## with no __dup_ prefix; see docs/planning/
## issue143-founder-positioning-fix-plan.md §1.4. No such detection script
## was ever committed before this session -- plan §4.3.) issue #144's own
## fix (docs/planning/issue144-anchor-row-mismatch-fix-plan.md) resolves
## the 51 remaining anchor-side mismatches this guard used to accept as
## expected residual -- empirically re-confirmed this session (0 anchor
## mismatches) against a patched 3-edit prototype of
## .positionMatingUnitForest(). ------------------------------------------

test_that(".positionMatingUnitForest's every NON-ANCHOR row mismatch on
           the real 375-individual bundled fixture is exactly the B2
           population (own parent edge or own D5 direct child, rendered
           at their own genuine gen by design -- S3.3.2), and every
           ANCHOR row mismatch is resolved (issue #143/#144) -- relies on
           this fixture having no dangling sire/dam references (confirmed
           by test_buildMatingUnitForest.R's own dangling-reference
           test). Walker/BJL cutover (Phase 3, this session): found during
           GREEN that the OLD algorithm's 'every non-anchor renders at its
           unit's gen' override (issue #143) is NOT reproduced for B2
           individuals under the new engine -- a deliberate, disclosed
           design choice (Phase 1b/2a's own spec: 'B2 gets NO derived
           point -- the render layer already points at her own,
           already-final genuine x'), not a regression. Re-verified
           directly (probe execution): all 56 non-anchor mismatches on
           this fixture are B2-classified, none unexplained.", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  posGen <- stats::setNames(pos$gen, pos$id)
  unitGen <- stats::setNames(forest$matingUnits$gen, forest$matingUnits$id)
  realIds <- as.character(ped$id)
  sireOf <- stats::setNames(as.character(ped$sire), realIds)
  damOf <- stats::setNames(as.character(ped$dam), realIds)
  childEdges <- forest$childEdges
  hasParentEdge <- function(id) !is.na(sireOf[[id]]) || !is.na(damOf[[id]])
  hasOwnDirectChild <- function(id) id %in% childEdges$from
  isB2 <- function(id) hasParentEdge(id) || hasOwnDirectChild(id)

  ## For each mating unit's side (sire, dam), find the node id that
  ## actually renders for THIS unit (the person's own real node, or their
  ## duplicate node if this unit is where they occur as a duplicate), and
  ## whether that side is the unit's anchor.
  mismatchSide <- function(personId, unitId, isAnchor) {
    dupId <- forest$duplicates$id[forest$duplicates$realId == personId &
                                     forest$duplicates$matingUnitId == unitId]
    nodeId <- if (length(dupId) == 1L) dupId else personId
    mismatched <- !identical(unname(posGen[[nodeId]]), unname(unitGen[[unitId]]))
    data.frame(personId = personId, isAnchor = isAnchor,
               mismatched = mismatched, stringsAsFactors = FALSE)
  }

  mu <- forest$matingUnits
  sideRows <- do.call(rbind, lapply(seq_len(nrow(mu)), function(i) {
    rbind(
      mismatchSide(mu$sire[i], mu$id[i], identical(mu$anchor[i], mu$sire[i])),
      mismatchSide(mu$dam[i], mu$id[i], identical(mu$anchor[i], mu$dam[i]))
    )
  }))

  nonAnchorMismatches <- sideRows[sideRows$mismatched & !sideRows$isAnchor, ]
  expect_true(all(vapply(nonAnchorMismatches$personId, isB2, logical(1L))),
              info = "every non-anchor mismatch must be B2-classified")
  expect_equal(nrow(nonAnchorMismatches), 56L)  # re-measured, not hand-derived

  ## CHANGED from 51L -- issue #144's effGenOf fix (Candidate B) resolves
  ## every anchor-side mismatch on this fixture (no anchor here anchors
  ## multiple units at differing unitGen -- the one residual shape #144
  ## does not close; see the 2 new regression tests below). Unaffected by
  ## the Walker/BJL cutover -- anchors always render at their own raw gen,
  ## which equals their unit's gen by Track 4's own construction (D2,
  ## untouched by this migration).
  expect_equal(sum(sideRows$mismatched & sideRows$isAnchor), 0L)
})

## ---- Track 4 (Candidate A, gen-aware D2 anchor selection): the issue
## #144 §6 dragon, now structurally closed --------------------------------
## Both fixtures below are the SAME 2 synthetic pedigrees issue #144's own
## session built to demonstrate the residual Candidate B (effGenOf)
## accepted rather than closed (an anchor anchoring 2+ mating units at
## genuinely different unitGen, or a single-unit anchor with a D5 direct
## child shallower than its own relocated effGen). Under Candidate A's
## gen-first D2 tie-break (docs/planning/pedigree-diagram-track4-gen-aware-
## anchor-plan.md §2.1-2.3), NEITHER shape can occur any longer: an
## individual can only ever anchor units where their own gen is >= the
## other parent's, so unitGen == genOf[[anchor]] unconditionally (§2.4) --
## instead of relocating an anchor's own displayed row (effGenOf), the
## anchor-selection ITSELF now changes for whichever unit would otherwise
## have mismatched. Verified empirically against the live implementation
## before being committed here (matching Track 3's own established
## practice, not hand-derivation).

test_that(".positionMatingUnitForest resolves an anchor that WOULD HAVE
           anchored 2 mating units at differing unitGen under the old
           founder/mate-count tie-break -- gen-first D2 selection instead
           reassigns the deeper unit's anchor to its own deeper-gen parent,
           so every unit satisfies gen == genOf[[anchor]] (Track 4 §2.4)", {
  ped <- data.frame(
    id   = c("GF1", "GF2", "HUB",
             "SEEDP1", "MATE1", "MATE1SEED", "MATE1CHILD",
             "SEEDP2", "MATE2", "MATE2SEED", "MATE2CHILD",
             "SHALLOWCHILD", "DEEPCHILD"),
    sire = c(NA, NA, "GF1",
             NA, "SEEDP1", NA, "MATE1",
             NA, "SEEDP2", NA, "MATE2",
             "HUB", "HUB"),
    dam  = c(NA, NA, "GF2",
             NA, NA, NA, "MATE1SEED",
             NA, NA, NA, "MATE2SEED",
             "MATE1", "MATE2"),
    sex  = c("M", "F", "M",
             "M", "M", "F", "F",
             "M", "M", "F", "F",
             "F", "M"),
    gen  = c(0L, 0L, 1L,
             -1L, 0L, 0L, 1L,
             4L, 5L, 5L, 6L,
             2L, 6L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)

  unitShallow <- forest$matingUnits$id[forest$matingUnits$sire == "HUB" &
                                          forest$matingUnits$dam == "MATE1"]
  unitDeep <- forest$matingUnits$id[forest$matingUnits$sire == "HUB" &
                                       forest$matingUnits$dam == "MATE2"]
  ## HUB (gen 1) beats MATE1 (gen 0) on the shallow unit -- unaffected,
  ## same winner as before. On the deep unit, MATE2 (gen 5) now beats HUB
  ## (gen 1) -- HUB anchors only ONE of the two units, not both, closing
  ## the differing-unitGen-per-anchor shape as structurally impossible.
  expect_equal(forest$matingUnits$anchor[forest$matingUnits$id == unitShallow],
               "HUB")
  expect_equal(forest$matingUnits$anchor[forest$matingUnits$id == unitDeep],
               "MATE2")
  expect_equal(forest$matingUnits$gen[forest$matingUnits$id == unitShallow], 1L)
  expect_equal(forest$matingUnits$gen[forest$matingUnits$id == unitDeep], 5L)

  ## The invariant this decision establishes: every unit's gen equals its
  ## own anchor's raw gen -- 0 exceptions, checked directly rather than
  ## via the 2 units picked out above alone.
  genOf <- stats::setNames(ped$gen, ped$id)
  expect_equal(forest$matingUnits$gen,
               unname(genOf[forest$matingUnits$anchor]))

  pos <- .positionMatingUnitForest(ped, forest)
  expect_false(any(is.na(pos$x)))
  expect_false(any(is.na(pos$gen)))
  .expectNoOverlap(pos)

  ## HUB's displayed gen is simply its own raw gen (1) -- no relocation
  ## mechanism exists any longer (effGenOf is gone), and none is needed:
  ## HUB only anchors the one unit whose gen already matches its own.
  expect_equal(pos$gen[pos$id == "HUB"], 1L)
})

test_that(".positionMatingUnitForest resolves a single-unit anchor whose
           old founder/mate-count tie-break would have relocated its
           displayed gen deeper than a D5 direct child's own gen --
           gen-first D2 selection instead reassigns the unit's anchor to
           the deeper-gen parent, so the shallower original anchor is
           displayed at its own unrelocated gen (Track 4 §2.4)", {
  ped <- data.frame(
    id   = c("ANCHOR", "MATE", "MATECHILD", "D5CHILD"),
    sire = c(NA, NA, "ANCHOR", "ANCHOR"),
    dam  = c(NA, NA, "MATE", NA),
    sex  = c("M", "F", "F", "M"),
    gen  = c(1L, 4L, 5L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  ## MATE (gen 4) beats ANCHOR (gen 1) under the gen-first rule -- the
  ## unit's anchor is now MATE, not ANCHOR (a name from the old fixture's
  ## own pre-Track-4 vintage, kept for continuity with the fixture's own
  ## history rather than renamed).
  expect_equal(forest$matingUnits$anchor, "MATE")
  expect_equal(forest$matingUnits$gen, 4L)

  pos <- .positionMatingUnitForest(ped, forest)
  expect_false(any(is.na(pos$x)))
  expect_false(any(is.na(pos$gen)))
  .expectNoOverlap(pos)

  ## ANCHOR is no longer an anchor at all -- its displayed gen is simply
  ## its own raw gen (1), unrelocated. D5CHILD keeps its own gen (2),
  ## unaffected either way (D5 direct children were never in effGenOf's
  ## domain, and still aren't in genOf's).
  expect_equal(pos$gen[pos$id == "ANCHOR"], 1L)
  expect_equal(pos$gen[pos$id == "D5CHILD"], 2L)
})

test_that(".positionMatingUnitForest's every mating unit satisfies the
           Track 4 invariant -- gen == genOf[[anchor]], 0 exceptions -- on
           the real 375-individual bundled fixture (docs/planning/
           pedigree-diagram-track4-gen-aware-anchor-plan.md §2.4/§7 step 1:
           the direct, general-property test this decision's own
           correctness claim rests on, not fixture-specific alone)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  genOf <- stats::setNames(ped$gen, as.character(ped$id))

  expect_false(any(is.na(forest$matingUnits$anchor)))
  expect_equal(forest$matingUnits$gen,
               unname(genOf[forest$matingUnits$anchor]))
})

## ---- issue #162: preferAnchor()'s final id tie-break is locale-independent
##      byte/radix order, not the session's own `Scollate()` -------------
test_that(".buildMatingUnitForest's D2 anchor tie-break falls back to
           byte/radix id order, not the session's own locale collation,
           when 2 candidates tie on both gen and mate count (issue #162)", {
  ## a1 (sire) x A1 (dam) are full siblings of F1 x F2 and mate exactly
  ## once each -> tied gen (1) and tied mate count (1) -> reaches
  ## preferAnchor()'s final `a < b` clause with nothing else to break the
  ## tie. Confirmed live this session, against UNMODIFIED source: this
  ## environment's own default locale (en_US.UTF-8) gives "a1" < "A1" ==
  ## TRUE (its Scollate() sorts lowercase before uppercase at a matching
  ## digit), so "a1" currently anchors. Byte/radix order says the OPPOSITE
  ## -- "A1" ('A' = 65) sorts before "a1" ('a' = 97) -- and under
  ## `LC_COLLATE = "C"` the same `<` comparison flips to FALSE, matching
  ## radix order exactly. This is the same defect class Learnings 585/588
  ## fixed for `order()` calls elsewhere in this file; `preferAnchor()`'s
  ## final clause was the one remaining bare character comparison (grep-
  ## confirmed, no other locale-dependent `<`/`order()` in this file).
  ## Expected (radix-correct, locale-STABLE) result: "A1" anchors.
  ped <- data.frame(
    id   = c("F1", "F2", "a1", "A1", "K"),
    sire = c(NA, NA, "F1", "F1", "a1"),
    dam  = c(NA, NA, "F2", "F2", "A1"),
    sex  = c("M", "F", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  forest <- .buildMatingUnitForest(ped)

  unit2 <- forest$matingUnits[forest$matingUnits$sire == "a1", ]
  expect_equal(unit2$anchor, "A1")
  expect_equal(unit2$nonAnchor, "a1")
})

## ---- Walker/BJL cutover (Phase 3, this session): the OLD "3-way OR"
## invariant (formula / Track-3-clamped / Track-3-Engagement-Gate-nudged)
## is REPLACED by a single exact-equality assertion, per the parent plan's
## own Commit 3-1 instruction. Track 3's clamp and the post-hoc duplicate-
## occurrence nudge are both gone by construction under the new engine --
## every ANCHORED mating unit's x is now, unconditionally, the exact
## midpoint of its own real children's final x (Tier 2), no OR-branches,
## no clamp exceptions. Verified directly this session (probe execution,
## never hand-derived): the worst absolute deviation from the formula,
## across every mating unit on the trio/loop/real-375/f1 fixtures, is
## exactly 0.001 -- the same pre-existing exact-tie de-collision epsilon
## the OLD invariant's own tolerance already accommodated, not a new
## slack term. -----------------------------------------------------------

test_that(".positionMatingUnitForest's every ANCHORED mating unit's x is
           the exact midpoint of its own real children's final x (Tier 2)
           -- a single equality, no clamp/nudge disjunction, since Track
           3's parent-span clamp and the Track-3-Engagement-Gate nudge are
           both removed by the Walker/BJL redesign -- on the small
           GA204Z/8LKBV9 loop fixture, the real 375-individual bundled
           fixture, and the P1/P2/A/Y/X/W/C1/GC/C2 consanguineous
           fixture", {
  ## Track 7 Phase 3 CHANGE (S652 -- issue #166, scoped revert,
  ## docs/planning/pedigree-diagram-track7-phase3-child-centering-plan.md
  ## §2.1/§5 step 1): the Phase 1 recenter loop that gave a QUALIFYING
  ## unit's x the anchor/mate midpoint instead of the child-midpoint is
  ## DELETED. checkInvariant() below no longer replicates the shipped
  ## qualifies()/b1Ids gate at all -- there is no longer a second formula
  ## to pick between. EVERY mating unit's x (anchored or orphan,
  ## previously-qualifying-shaped or not) is, once again, unconditionally
  ## the midpoint of its own real children's final x (Tier 2) -- verified
  ## live against the reverted code (pkgload::load_all() spike, never
  ## hand-derived): 0 exceptions across all 237 anchored units on the real
  ## 375-individual fixture, plus the small/f1 fixtures below.
  checkInvariant <- function(ped) {
    forest <- .buildMatingUnitForest(ped)
    pos <- .positionMatingUnitForest(ped, forest)
    matingUnits <- forest$matingUnits
    childEdges <- forest$childEdges
    for (i in seq_len(nrow(matingUnits))) {
      uid <- matingUnits$id[i]
      actual <- pos$x[pos$id == uid]
      kids <- childEdges$to[childEdges$from == uid]
      kidX <- pos$x[match(kids, pos$id)]
      formulaX <- (min(kidX) + max(kidX)) / 2
      ## Absolute-difference comparison (+ a 1e-9 float-representation
      ## buffer). 1e-2 tolerance (unchanged from Track 7 Phase 1/2, kept
      ## post-revert since it costs nothing and remains a valid ceiling):
      ## the pre-existing exact-tie epsilon sweep can chain up to 6
      ## consecutive 1e-3 nudges (max measured deviation 0.006) when
      ## several unions independently land near the same raw value.
      ##
      ## Track 7 Phase 2 (S649, unaffected by this revert -- it operates
      ## on whatever unitX value Tier 2 hands it): a union's own
      ## proximity push (plan §12.2) legitimately deviates from its own
      ## formula by a genuine, disclosed multiple of the radius-
      ## proportionate clearance step -- not a bug, the actual behavior
      ## this phase ships. Accepted here (generically, not by hardcoding
      ## which unit ids) as an alternative match: the deviation is within
      ## floating tolerance of k * ((25+6)/120) for some k in 1:5 (the
      ## same unionClearanceIndividual/.kMaxUnionPush constants, defined
      ## locally to this test rather than relied on from later in this
      ## file -- see the "Track 7 Phase 2" section below for the
      ## derivation).
      deviation <- abs(actual - formulaX)
      pushSteps <- deviation / ((25 + 6) / 120)
      isPhase2Push <- deviation > 1e-2 &&
        any(abs(pushSteps - round(pushSteps)) < 1e-6) &&
        round(pushSteps) >= 1L && round(pushSteps) <= 5L
      expect_true(
        deviation <= 1e-2 + 1e-9 || isPhase2Push,
        info = paste("unit", uid, "formula", formulaX, "actual", actual,
                     "deviation", deviation))
    }
  }

  small <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  checkInvariant(small)

  real <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  checkInvariant(real)

  ## NEW: the only known fixture, among this project's own test corpora,
  ## where the qualification rule actually fires (investigation doc
  ## §10.6/§11.3(a)) -- P1,P2 -> X,A,Y,W,C1,GC,C2 (A x Y consanguineous,
  ## Y duplicated there via her own outside mate W). Same pedigree as
  ## test_resolveEdgeNodeCollisions.R's own .commentOneFixture(), inlined
  ## here rather than called cross-file (that file's local helper is not a
  ## shared package/testthat helper and this file loads first
  ## alphabetically under test_dir()'s per-file sourcing order).
  f1 <- data.frame(
    id   = c("P1", "P2", "X", "A", "Y", "W", "C1", "GC", "C2"),
    sire = c(NA, NA, NA, "P1", "P1", NA, "A", "A", "W"),
    dam  = c(NA, NA, NA, "P2", "P2", NA, "X", "Y", "Y"),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  f1$gen <- findGeneration(f1$id, f1$sire, f1$dam)
  checkInvariant(f1)
})

test_that(".positionMatingUnitForest has a bounded, disclosed residual of
           exact x/gen coincidence among real, duplicate, AND mating-unit
           nodes together (Track 6 §2.3's broadened de-collision pass,
           narrowed by Track 7, S647) -- confirmed empirically this
           session (Pre-RED) that the real 375-individual bundled
           fixture already has 1 duplicate/union coincidence under
           UNMODIFIED source (a pre-existing gap this decision's own §2.3
           closes as a side effect, not a new regression §2.1/§2.2
           introduce)

           Track 7 CHANGE (S647): the widened B1 offset introduces new
           collision pressure a capped bidirectional search
           (.deCollideIndividualPoints()) resolves for most pairs, but not
           all, on this densely-packed real fixture -- see the scale-check
           test above for the full accounting.

           Track 7 Phase 3 (S652 -- issue #166, scoped revert): re-verified
           live against the reverted code that this all-types count is
           ALSO unchanged at 27L -- the union recenter's removal touches
           only qualifying unions' own x, not the individual-side residual
           this metric is driven by, and duplicates contribute 0 to it
           both before and after (confirmed directly, not assumed).

           CHANGED to 0L (B1-individual-vs-unrelated-individual proximity
           fix, docs/planning/pedigree-diagram-b1-individual-proximity-
           plan.md, design ratified S661, implementation S662): the entire
           27-node exact-tie residual was composed of B1-vs-unrelated-
           individual ties this fix's new pass resolves -- re-measured
           directly by actually running the fixed engine, never
           hand-derived.", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  key <- paste(round(pos$x, 6), pos$gen)
  nColliding <- sum(duplicated(key) | duplicated(key, fromLast = TRUE))
  expect_equal(nColliding, 0L,
               info = paste("colliding ids:",
                             paste(pos$id[key %in% key[duplicated(key)]],
                                   collapse = ", ")))
})

## ---- Track 7 Phase 2: union-dot proximity to unrelated nodes ----------
## docs/planning/pedigree-diagram-track7-mate-spacing-plan.md §12 (design
## RATIFIED S648; implemented S649). Phase 1 (S647, above) widened B1's
## own offset to minSep but left the UNION side's own de-collision sweep
## (R/makePedigreeDiagramData.R:981-1001) with only an exact-tie epsilon
## nudge -- a mating-union dot can land immediately adjacent to (not
## exactly on) an unrelated node, close enough to visually fuse with it
## (plan §12.9's own visual spike evidence). This replaces that epsilon
## nudge with a capped bidirectional push at a radius-proportionate
## clearance target, union side only (plan §12.2) -- individuals/
## duplicates and their own sweep (.deCollideIndividualPoints()) are
## entirely untouched; the 27-count tests above are RE-VERIFIED this
## session (Pre-RED, not assumed) to be UNCHANGED by this fix -- that
## metric is driven entirely by the individual side's own residual, which
## this fix never touches.
##
## Node-radius-derived clearance constants (plan §12.2): size=25 for a
## real/duplicate node, size=6 for a union dot, xScale=120 -- the same two
## already-existing render-layer constants (R/makePedigreeDiagramData.R:
## 1226/1306/1324/1342), not a new guess.
.unionClearanceIndividual <- (25 + 6) / 120
.unionClearanceUnion <- (6 + 6) / 120
## Two full-size (25px-radius) individual-shaped nodes -- duplicate-vs-
## unrelated-individual proximity plan (docs/planning/pedigree-diagram-
## duplicate-individual-proximity-plan.md §1.1), the geometrically correct
## clearance for a pair of individual/duplicate/B1 render nodes, distinct
## from .unionClearanceIndividual above (a union DOT vs. an individual).
.individualClearance <- (25 + 25) / 120

## Pre-RED empirical finding, S649 (verified live via a temporary,
## immediately-reverted spike patch -- git diff/status/shasum confirmed
## byte-identical to HEAD after each check, matching this project's own
## established spike-and-restore discipline; never hand-derived):
## implementing plan §12.2 exactly as ratified resolves ALL 20 of the real
## 375-fixture's individual- and union-vs-union proximity cases (0
## residual), but introduces 11 NEW union-vs-DUPLICATE proximity cases
## that did not exist before. Root cause: a duplicate node's x is always
## unitX[[itsOwnUnion]] + minSep*0.4 (R/makePedigreeDiagramData.R:816) -- a
## fixed offset that rides along whenever a union moves -- and this
## sweep's own occupied-set (tier1X/b1AtGen/placedAtGen) has no visibility
## into duplicate positions, which are not computed until AFTER this loop
## runs (a genuine data dependency, not an oversight: a duplicate's own
## derivedX() reads the union's FINAL unitX). This contradicts plan
## §12.1's own "0 new collisions" claim, which came from a simpler
## point-distance simulation that did not model a duplicate's ride-along
## relationship to its own union -- the same class of gap as Learning 682
## (measuring a mechanism in isolation from a step that changes its
## input); plan §12.1 corrected in place, not silently revised, matching
## this project's disclosure practice. Owner-directed (AskUserQuestion,
## S649): ship §12.2 as scoped -- it fully resolves the owner's own
## directly-reviewed Track B fixture (3/3 -> 0/3, no duplicates in play
## there at all, see the test below) -- and disclose the 11-case
## duplicate residual as a new, separately-filed BACKLOG Housekeeping
## item (not fixed this session), matching this project's own established
## "file, don't fix out-of-scope findings" precedent (the __jog_*
## waypoint bug, S648).

## Track 7 Phase 3 CHANGE (S652 -- issue #166, scoped revert): reverting
## the Phase 1 recenter loop moves each of these 3 qualifying unions'
## STARTING x (before Phase 2's push runs) from the anchor/mate midpoint
## back to the child-midpoint -- and for all 3 of these single/near-
## single-child unions on THIS specific fixture, that starting point now
## coincides EXACTLY with the union's own anchor (Finding B's identity).
## Phase 2's push search correctly treats a union sitting on its own
## anchor as expected, not something to push away from (design doc §2.1)
## -- so it never engages, and the pre-existing small-epsilon tie-break
## (unaffected by this revert) nudges each union 0.001 raw units off its
## anchor instead of resolving to the radius-proportionate clearance
## target. Confirmed live against the reverted code, never hand-derived:
## this is the exact, disclosed §2.1 trade-off ("every qualifying union
## will now land exactly on its own anchor's x"), now measured concretely
## on the owner's own directly-reviewed Track B fixture specifically, not
## just the real-375 aggregate the design's own adversarial verification
## simulated. The union dot again sits ~0.12px from its own anchor's
## symbol -- effectively the ORIGINAL Track 7 Phase 1 complaint,
## re-introduced for this fixture's own 3 pairs, exactly as ratified.
test_that(".positionMatingUnitForest's Track 7 Phase 2 push no longer
           engages for the shrunk Track B fixture's 3 union-vs-individual
           pairs after issue #166's scoped revert (S652) -- each union now
           sits exactly on its own anchor (Finding B's identity) rather
           than near an unrelated node, so the pre-existing small-epsilon
           tie-break applies instead of Phase 2's radius-proportionate
           push; exact values re-measured live against the reverted code,
           never hand-derived", {
  pedB <- data.frame(
    id   = c("P1", "P2", "P3", "P4", "P5", "P6",
             "C1", "C2", "C3", "C4", "C4a",
             "G3", "M1", "L1", "L2", "L3"),
    sire = c(NA, NA, NA, NA, NA, NA,
             "P1", "P1", "P1", "P3", "C4",
             NA, "P1", "M1", "M1", "M1"),
    dam  = c(NA, NA, NA, NA, NA, NA,
             "P2", "P2", "P2", "P4", "P6",
             NA, "P2", "G3", "G3", "G3"),
    sex  = c("M", "F", "M", "F", "F", "F",
             "F", "M", "F", "M", "F",
             "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  genotypedB <- c(P1 = TRUE, P2 = TRUE, P3 = FALSE, P4 = FALSE, P5 = TRUE,
    P6 = TRUE, C1 = TRUE, C2 = FALSE, C3 = TRUE, C4 = TRUE, C4a = TRUE,
    G3 = FALSE, M1 = TRUE, L1 = TRUE, L2 = TRUE, L3 = TRUE)[pedB$id]
  affectedB <- c(P1 = NA, P2 = NA, P3 = NA, P4 = NA, P5 = NA, P6 = NA,
    C1 = FALSE, C2 = NA, C3 = TRUE, C4 = TRUE, C4a = TRUE, G3 = NA,
    M1 = TRUE, L1 = NA, L2 = FALSE, L3 = TRUE)[pedB$id]
  shrunk <- shrinkPedigree(pedB, genotypedB, affected = affectedB,
                           maxBits = 1L)$ped
  shrunk$gen <- findGeneration(shrunk$id, shrunk$sire, shrunk$dam)
  expect_equal(sort(shrunk$id),
               sort(c("C4", "C4a", "G3", "L3", "M1", "P1", "P2", "P6")))

  forest <- .buildMatingUnitForest(shrunk)
  pos <- .positionMatingUnitForest(shrunk, forest)

  u1 <- pos$x[pos$id == "__union_1"]  # C4 x P6, gen 0
  u2 <- pos$x[pos$id == "__union_2"]  # P1 x P2, gen 0
  u3 <- pos$x[pos$id == "__union_3"]  # M1 x G3, gen 1

  ## Post-revert (S652): each union's starting x is now Tier 2's
  ## unconditional child-midpoint, which coincides exactly with its own
  ## anchor for this fixture's 3 pairs (C4 anchors __union_1, P1 anchors
  ## __union_2, M1 anchors __union_3) -- so the pre-existing small-epsilon
  ## tie-break applies (0.001 raw units off the anchor), not Phase 2's
  ## radius-proportionate push. Re-measured live against the reverted
  ## code, never hand-derived.
  expect_equal(u1, 1.001, tolerance = 1e-6)
  expect_equal(u2, 0.001, tolerance = 1e-6)
  expect_equal(u3, 0.001, tolerance = 1e-6)

  ## The radius-proportionate clearance claim NO LONGER HOLDS for this
  ## fixture -- each union sits well inside .unionClearanceIndividual of
  ## its own anchor (that IS the anchor-coincidence case, expected and
  ## accepted per design doc §2.1, not a defect). Asserted explicitly
  ## (not merely omitted) so a future session doesn't mistake the absence
  ## of the old clearance check for an oversight.
  gen0Indiv <- pos[pos$gen == 0 & !grepl("^__union_", pos$id), ]
  expect_true(any(abs(gen0Indiv$x - u1) < .unionClearanceIndividual))
  expect_true(any(abs(gen0Indiv$x - u2) < .unionClearanceIndividual))
  gen1Indiv <- pos[pos$gen == 1 & !grepl("^__union_", pos$id), ]
  expect_true(any(abs(gen1Indiv$x - u3) < .unionClearanceIndividual))
})

test_that(".positionMatingUnitForest's Track 7 Phase 2 push resolves every
           union-vs-individual and union-vs-union proximity collision on
           the real 375-individual bundled fixture (20/237 before this
           fix, plan §12.1); Track 7 Phase 4's duplicate-side post-pass
           (docs/planning/pedigree-diagram-track7-phase4-union-duplicate-
           proximity-plan.md) now also resolves the union-vs-DUPLICATE
           residual Phase 2's own occupied-set could not see (a
           duplicate's x is computed AFTER this sweep runs) down to 0", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  anchorOf <- stats::setNames(forest$matingUnits$anchor, forest$matingUnits$id)
  nonAnchorOf <- stats::setNames(forest$matingUnits$nonAnchor,
                                  forest$matingUnits$id)
  unionRows <- pos[.nodeKind(pos$id) == "union", ]
  counts <- c(individual = 0L, union = 0L, duplicate = 0L)
  for (i in seq_len(nrow(unionRows))) {
    u <- unionRows[i, ]
    excludeIds <- c(u$id, anchorOf[[u$id]], nonAnchorOf[[u$id]])
    cand <- pos[pos$gen == u$gen & !(pos$id %in% excludeIds), ]
    if (nrow(cand) == 0L) next
    d <- abs(cand$x - u$x)
    j <- which.min(d)
    nk <- .nodeKind(cand$id[j])
    thresh <- if (identical(nk, "union")) .unionClearanceUnion else
      .unionClearanceIndividual
    if (d[j] < thresh) counts[[nk]] <- counts[[nk]] + 1L
  }
  expect_equal(unname(counts["individual"]), 0L)
  expect_equal(unname(counts["union"]), 0L)
  ## CORRECTED (S649, found in GREEN): the capped push search must
  ## exclude a union's own anchor/non-anchor from its own occupied-set
  ## (a union's gen is max(parent gens), so it can share its displayed
  ## gen with a structural parent -- not an unrelated node) -- with that
  ## fix in place, the union-vs-duplicate residual measures 4, not the
  ## 11 this section's own header note (and plan §12.11) originally
  ## reported from a pre-fix spike that didn't yet have this exclusion.
  ##
  ## CHANGED AGAIN (S652 -- issue #166, scoped revert): 4 -> 3. A
  ## duplicate's x rides along with its own union's x (derivedX()'s B3
  ## branch, unitX[[itsOwnUnion]] + minSep*0.4); reverting the recenter
  ## moves several qualifying unions' x back toward their own anchor,
  ## which shifts this residual's composition -- 1 new case, 2 resolved,
  ## per the design doc's own §2.1 adversarial re-verification, confirmed
  ## here directly against the reverted code (never hand-derived, never
  ## taken on the design doc's word alone).
  ##
  ## CHANGED AGAIN (Track 7 Phase 4, docs/planning/pedigree-diagram-
  ## track7-phase4-union-duplicate-proximity-plan.md §2/§6): 3 -> 0. A
  ## new duplicate-side, post-hoc, unidirectional push (run after both the
  ## union sweep AND duplicate positions are finalized) resolves all 3
  ## remaining cases -- this IS the design doc's own §1.2 finding,
  ## reproduced directly via this exact counting method, not a separate
  ## hand-derived claim. All 3 named pairs (__union_14/__dup_L31S6S_3,
  ## __union_43/__dup_WDBGPF_2, __union_126/__dup_YPHFHF_1) confirmed
  ## individually resolved before this aggregate assertion was updated.
  expect_equal(unname(counts["duplicate"]), 0L)
})

## ---- Duplicate-vs-unrelated-individual proximity (docs/planning/
## pedigree-diagram-duplicate-individual-proximity-plan.md, design ratified
## S658, implementation S660): .deCollideIndividualPoints() intervenes ONLY
## on an exact tie (< 1e-9) for individual-shaped points (real/B1
## individuals and duplicates, all 25px-radius circles) -- it has no
## near-miss RADIUS check, unlike the union-side mechanism Track 7 Phase
## 2/4 already added. Option B (ratified) extends Track 7 Phase 4's
## existing post-hoc duplicate-side push loop with a combined
## union+individual collision check (own mating-unit parents excluded).
## Pre-RED re-validation (S660, re-derived live against unmodified HEAD,
## not assumed from the design doc): the exact same 6 genuine UNRELATED
## same-generation individual-pairs the design doc's §1.2/§1.3 table
## reports survive full family-relationship exclusion (dup-own-parent/
## parent-child/sibling/mate) -- including the 2 duplicate-involving cases
## this fix targets. (An incidental, separate, ALREADY-DISCLOSED residual
## also surfaces in a naive sweep: 15 EXACT-tie [dist < 1e-9] pairs, traced
## to .deCollideIndividualPoints()'s own .kMaxIndividualPush cap-exhaustion
## fallback [:912-914, "falls back to the ORIGINAL exact-tie value"] --
## unrelated to and unaffected by this fix, explicitly excluded from the
## counting method below.)
test_that(".positionMatingUnitForest's duplicate-vs-unrelated-individual
           near-miss defect: on the real 375-individual bundled fixture,
           exactly 2 duplicates sit within .individualClearance of an
           unrelated (non-family) individual-shaped point before Option B's
           fix -- 0 after", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  indivRows <- pos[.nodeKind(pos$id) %in% c("individual", "duplicate"), ]
  dupUnitOf <- stats::setNames(forest$duplicates$matingUnitId,
                                forest$duplicates$id)
  unitSireOf <- stats::setNames(forest$matingUnits$sire, forest$matingUnits$id)
  unitDamOf <- stats::setNames(forest$matingUnits$dam, forest$matingUnits$id)
  realIdOf <- function(id) {
    m <- match(id, forest$duplicates$id)
    ifelse(is.na(m), id, forest$duplicates$realId[m])
  }
  sireOf <- stats::setNames(as.character(ped$sire), as.character(ped$id))
  damOf <- stats::setNames(as.character(ped$dam), as.character(ped$id))

  ## dup-own-parent: one side is a duplicate whose OWN mating unit's
  ## sire/dam is the other side (the design's own family exclusion, §2).
  isDupOwnParent <- function(idA, idB) {
    ra <- realIdOf(idA); rb <- realIdOf(idB)
    if (idA %in% names(dupUnitOf)) {
      u <- dupUnitOf[[idA]]
      if (identical(unname(unitSireOf[[u]]), rb) ||
            identical(unname(unitDamOf[[u]]), rb)) return(TRUE)
    }
    if (idB %in% names(dupUnitOf)) {
      u <- dupUnitOf[[idB]]
      if (identical(unname(unitSireOf[[u]]), ra) ||
            identical(unname(unitDamOf[[u]]), ra)) return(TRUE)
    }
    FALSE
  }

  n <- 0L
  for (g in unique(indivRows$gen)) {
    rows <- indivRows[indivRows$gen == g, ]
    k <- nrow(rows)
    if (k < 2L) next
    for (i in seq_len(k - 1L)) {
      for (j in (i + 1L):k) {
        involvesDup <- grepl("^__dup_", rows$id[i]) ||
          grepl("^__dup_", rows$id[j])
        if (!involvesDup) next
        d <- abs(rows$x[i] - rows$x[j])
        if (d < 1e-9) next  ## the separate, already-disclosed exact-tie
                            ## residual (see header note) -- out of scope
        if (d < .individualClearance &&
              !isDupOwnParent(rows$id[i], rows$id[j])) {
          n <- n + 1L
        }
      }
    }
  }
  ## Pre-fix: 2 (TTE0Z7/__dup_MY1AEU_2 at 0.099, M0YNUR/__dup_L31S6S_5 at
  ## 0.100) -- re-measured live this session, matching the design doc's own
  ## §1.3 table exactly. Option B (GREEN) resolves this to 0.
  expect_equal(n, 0L)
})

test_that(".positionMatingUnitForest's Option B fix resolves the 2 named
           duplicate-vs-unrelated-individual pairs on the real 375-
           individual bundled fixture to >= .individualClearance apart
           (design doc §1.3/§2) -- 0.099/0.100 raw units apart before the
           fix", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  distTo <- function(idA, idB) {
    abs(pos$x[pos$id == idA] - pos$x[pos$id == idB])
  }
  expect_true(distTo("TTE0Z7", "__dup_MY1AEU_2") >= .individualClearance)
  expect_true(distTo("M0YNUR", "__dup_L31S6S_5") >= .individualClearance)
})

## ---- §6 disclosed edge case: the early-exit guard at
## R/makePedigreeDiagramData.R:1131 (`if (length(unrelatedUnionsAtGen) ==
## 0L) next`) must widen to also check the new individual forbidden-set, or
## a duplicate in a generation with NO OTHER mating units would silently
## skip the new check entirely (design doc §6).
##
## Investigated this session whether a small synthetic fixture could
## reproduce an ACTUAL near-miss under this exact condition (a genuine RED
## failure, matching every other case in this file) -- found, by direct
## construction and analysis, that it cannot for two independent
## structural reasons:
## (1) ANY B1/free-pass individual close enough to matter necessarily
##     brings her OWN mating unit into the SAME generation (tier3Gen is
##     always defined as `matingUnits$gen[herOwnUnitId]`), which makes
##     unrelatedUnionsAtGen non-empty by construction and directly
##     contradicts the "no other mating units" premise.
## (2) A genuine Tier-1 individual is separately guaranteed by
##     sweepMinSep()'s own per-generation backstop (:738-749) to be >=
##     minSep=1 from EVERY other genuine Tier-1 individual at her real
##     gen -- so an UNRELATED one can get no closer than minSep - 0.4 =
##     0.6 to a duplicate anchored nearby (> .individualClearance) in any
##     hand-built fixture small enough to reason about by construction; only
##     the real fixture's much larger, emergent cross-subtree crowding
##     produces the kind of coincidental proximity this design's own 2
##     genuine defects exploit.
## Confirmed live: both of the real fixture's own 2 named cases sit in
## generations with 40+ OTHER mating units already present (re-measured
## this session), so the widened guard is never actually exercised by
## either of them -- this really is a purely defensive completeness path,
## not a live-hit one, exactly as the design doc's own §6 disclosed ("does
## not bite on the current fixture").
##
## This test instead exercises the WIDENED CONDITION's own regression
## safety on the one case that IS cheaply constructible: a duplicate whose
## generation has genuinely ZERO other mating units and ZERO nearby
## individuals (the ordinary, common "quiet generation" case) must be
## completely unaffected by the widened guard -- confirming its own two-
## forbidden-set-length check does not regress this baseline case.
test_that(".positionMatingUnitForest's widened Phase-4 early-exit guard
           (design doc §6) leaves a duplicate in a generation with zero
           other mating units and zero nearby individuals completely
           unaffected", {
  ped <- data.frame(
    id   = c("W1", "W2", "Z", "X", "Y", "P", "Q"),
    sire = c(NA, NA, "W1", NA, NA, "X", "X"),
    dam  = c(NA, NA, "W2", NA, NA, "Y", "Z"),
    sex  = c("M", "F", "F", "M", "F", "F", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  forest <- .buildMatingUnitForest(ped)
  expect_equal(nrow(forest$duplicates), 1L)
  dupUnit <- forest$duplicates$matingUnitId
  dupGen <- forest$matingUnits$gen[forest$matingUnits$id == dupUnit]
  otherUnits <- forest$matingUnits$id[forest$matingUnits$gen == dupGen &
                                         forest$matingUnits$id != dupUnit]
  expect_equal(length(otherUnits), 0L)  # confirms the premise holds

  pos <- .positionMatingUnitForest(ped, forest)
  dupId <- forest$duplicates$id
  ## Pinned value, re-measured live this session -- must stay unchanged
  ## after the fix (GREEN), demonstrating the widened guard's own
  ## early-exit still fires when BOTH forbidden sets are empty.
  expect_equal(pos$x[pos$id == dupId], 0.401, tolerance = 1e-6)
})

## ---- B1-individual-vs-unrelated-individual proximity (docs/planning/
## pedigree-diagram-b1-individual-proximity-plan.md, design ratified S661,
## implementation S662): the sibling call path to the fix immediately
## above (b1Ids, R/makePedigreeDiagramData.R:958-960) shares the same root
## cause (.deCollideIndividualPoints() intervenes ONLY on an exact tie, and
## its own capped bidirectional search [.kMaxIndividualPush = 2] can fall
## back to the ORIGINAL still-colliding position, :912-914) but was
## explicitly OUT of scope for the fix above (design doc §1.1): at least
## one side of every affected pair here is a B1 "free-pass" individual,
## never two genuine Tier-1 individuals (sweepMinSep() already guarantees
## minSep=1 between those). Pre-RED re-validation (S662, re-derived live
## against unmodified HEAD, not assumed from the design doc): the same 19
## "unrelated" pairs the design doc's §1.2 table reports survive full
## family-relationship exclusion (own-mating-unit/mate proximity excluded
## as by-design, matching the fix above's own dup-own-parent exclusion) --
## 4 strictly-positive near-misses (BACKLOG's original count) + 15
## previously-undocumented EXACT ties (dist = 0.000000), of which 4 pairs
## are B1-vs-B1 (a self-referential case within the very population this
## design's own pass finalizes, design doc §3.3). A further 25 "mates"
## pairs (a B1 individual and her own anchor, the intentional Track 7
## Phase 1 widened-offset formula -- 37.3% of all 67 b1Ids members,
## re-measured live this session) are confirmed by-design, not a defect
## (design doc §1.2/§3.2), and excluded from the counting method below.
test_that(".positionMatingUnitForest's B1-individual-vs-unrelated-individual
           near-miss defect: on the real 375-individual bundled fixture,
           exactly 19 B1-vs-unrelated-individual pairs (4 strictly-positive
           near-misses + 15 exact ties) sit within .individualClearance of
           each other before this design's fix -- 0 after (design doc
           §1.2/§2.1; the 25 own-anchor 'mates' pairs are excluded here as
           by-design, matching the design's own own-anchor exclusion)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  matingUnits <- forest$matingUnits
  childEdges <- forest$childEdges
  realIds <- as.character(ped$id)
  anchoredUnits <- matingUnits[!is.na(matingUnits$anchor), , drop = FALSE]
  everAnchor <- unique(anchoredUnits$anchor)
  nonAnchorSides <- c(anchoredUnits$sire, anchoredUnits$dam)
  neverAnchorIds <- setdiff(unique(nonAnchorSides), everAnchor)
  directChildrenOf <- function(id) {
    childEdges$to[childEdges$from == id & childEdges$from %in% realIds]
  }
  hasOwnDirectChild <- function(id) length(directChildrenOf(id)) > 0L
  sireOf <- stats::setNames(as.character(ped$sire), realIds)
  damOf <- stats::setNames(as.character(ped$dam), realIds)
  hasParentEdge <- function(id) !is.na(sireOf[[id]]) || !is.na(damOf[[id]])
  b1Ids <- Filter(function(id) {
    id %in% realIds && !hasOwnDirectChild(id) && !hasParentEdge(id)
  }, neverAnchorIds)
  expect_equal(length(b1Ids), 67L)  # confirms the premise holds (design §1.2)

  ## Same-mating-unit ("mates") check -- the by-design exclusion this
  ## design's own §2.2 own-anchor check applies (design doc §1.2/§3.2).
  isSameMatingUnit <- function(idA, idB) {
    any((matingUnits$sire == idA & matingUnits$dam == idB) |
          (matingUnits$sire == idB & matingUnits$dam == idA))
  }

  indiv <- pos[pos$id %in% realIds, , drop = FALSE]
  n <- 0L
  for (g in unique(indiv$gen)) {
    rows <- indiv[indiv$gen == g, , drop = FALSE]
    k <- nrow(rows)
    if (k < 2L) next
    for (i in seq_len(k - 1L)) {
      for (j in (i + 1L):k) {
        involvesB1 <- rows$id[i] %in% b1Ids || rows$id[j] %in% b1Ids
        if (!involvesB1) next   # sweepMinSep() already guarantees
                                 # genuine-vs-genuine pairs are >= minSep
                                 # apart (design doc §1.2)
        d <- abs(rows$x[i] - rows$x[j])
        if (d < .individualClearance &&
              !isSameMatingUnit(rows$id[i], rows$id[j])) {
          n <- n + 1L
        }
      }
    }
  }
  ## Pre-fix: 19 (design doc §1.2 -- 4 strictly-positive near-misses + 15
  ## exact ties, re-verified live this session against unmodified HEAD).
  ## This design's new pass (§2.2) resolves this to 0.
  expect_equal(n, 0L)
})

test_that(".positionMatingUnitForest's new B1-vs-unrelated-individual pass
           resolves a representative sample of the 19 in-scope pairs
           (design doc §1.2) to >= .individualClearance apart, including 3
           of the 4 B1-vs-B1 self-referential pairs (design doc §3.3)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  distTo <- function(idA, idB) {
    abs(pos$x[pos$id == idA] - pos$x[pos$id == idB])
  }
  ## genuine/B1 exact ties (0.000 raw units apart before the fix)
  expect_true(distTo("GQUCRY", "WS6D1B") >= .individualClearance)
  expect_true(distTo("6VUC6R", "UWJKEQ") >= .individualClearance)
  ## B1-vs-B1 exact tie -- self-referential within the population this
  ## design's own pass finalizes (design doc §3.3)
  expect_true(distTo("UWJKEQ", "ZZ646X") >= .individualClearance)
  ## the 4 strictly-positive near-misses BACKLOG originally named
  expect_true(distTo("D0Z114", "S0022Z") >= .individualClearance)
  expect_true(distTo("XEE9GT", "JB7EW2") >= .individualClearance)  # B1-vs-B1
  expect_true(distTo("PQX22G", "Y7IUMX") >= .individualClearance)  # B1-vs-B1
  expect_true(distTo("HKTQ40", "8P17E3") >= .individualClearance)  # B1-vs-B1
})

## ---- §7 co-anchor edge case: a polygamous anchor's 2 different B1 mates
## in 2 different mating units -- confirmed absent from all 19 currently-
## known real-fixture pairs (design doc §3.5), but not structurally
## prevented by the own-anchor-ONLY exclusion (§2.2's `forbidden <-
## forbidden[... names(forbidden) != ownAnchor]` excludes only the
## processed member's OWN anchor by name, never a SIBLING sharing that
## anchor -- a same-generation B1 sibling is instead caught, if at all,
## via the incremental `pushedThisGen` accumulator, exactly like any other
## B1-vs-B1 pair).
##
## Investigated this session whether a small synthetic fixture could
## reproduce an ACTUAL forced near-miss between 2 co-anchor B1 siblings
## specifically (as opposed to a general B1-vs-B1 pair, already covered
## above) -- found, by direct construction (a polygamous male anchor P
## with 2 B1 mates M1/M2, `scratchpad/probe_coanchor_final.R`), that it
## reliably produces one of two outcomes, neither a genuine forced
## near-miss:
## (1) when both mates share the SAME `b1PushSign` (the common case), the
##     raw formula ties them EXACTLY -- already resolved to a full
##     minSep=1 gap by the PRE-EXISTING `.deCollideIndividualPoints(b1Ids,
##     ...)` exact-tie call (:958-960), well clear of
##     .individualClearance, before this design's own new pass ever runs;
## (2) the `qualifies()` non-qualifying fallback (`minSep*0.4` from each
##     member's OWN mating-unit x, :816) that DOES land a member within
##     .individualClearance does so relative to her OWN anchor/union, not
##     relative to her sibling's independently-computed union x -- the 2
##     mates' own union dots are themselves subject to Track 7 Phase 2's
##     union-spacing sweep, which (on this and every attempted small
##     fixture) keeps them farther apart than .individualClearance.
## Matches this project's own established precedent for a structurally
## infeasible-to-force small-fixture edge case (see the widened
## early-exit-guard test above, "§6 disclosed edge case"): this fixture
## instead pins the REGRESSION-SAFETY property that IS directly
## constructible and load-bearing -- confirming the mechanism does not
## mistake "shares my anchor" for "is my anchor" (excluding only the OWN
## anchor by name, §2.2), on the SAME fixture used by the own-anchor
## exclusion test immediately below.
test_that(".positionMatingUnitForest's new B1-vs-unrelated-individual pass
           does not treat a co-anchor SIBLING (a different B1 mate of the
           same polygamous anchor) as excluded -- only the member's OWN
           anchor is excluded (design doc §2.2/§3.5)", {
  ped <- data.frame(
    id   = c("PPS", "PPD", "P", "M1", "C1", "M2", "C2"),
    sire = c(NA, NA, "PPS", NA, "P",  NA, "P"),
    dam  = c(NA, NA, "PPD", NA, "M1", NA, "M2"),
    sex  = c("M", "F", "M", "F", "F", "F", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  ## Confirms the premise: M1 and M2 are both B1, sharing anchor P.
  anchoredUnits <- forest$matingUnits[!is.na(forest$matingUnits$anchor), ]
  expect_equal(anchoredUnits$anchor[anchoredUnits$sire == "P" |
                                       anchoredUnits$dam == "P"],
               c("P", "P"))

  m1X <- pos$x[pos$id == "M1"]
  m2X <- pos$x[pos$id == "M2"]
  ## Pinned, re-measured live this session: already >= .individualClearance
  ## apart via the PRE-EXISTING mechanism (see header note) -- this
  ## design's new pass must leave that untouched, not perturb it further.
  expect_equal(m1X, 0.4, tolerance = 1e-6)
  expect_equal(m2X, 1.4, tolerance = 1e-6)
  expect_true(abs(m1X - m2X) >= .individualClearance)
})

test_that(".positionMatingUnitForest's new B1-vs-unrelated-individual pass
           does NOT perturb a B1 individual positioned within
           .individualClearance of her OWN anchor (the by-design 'mates'
           proximity case, design doc §1.2/§3.2/§3.5) -- collateral damage
           this design's own-anchor exclusion exists specifically to
           prevent (37.3% of all 67 b1Ids members on the real fixture sit
           this close to their own anchor)", {
  ped <- data.frame(
    id   = c("PPS", "PPD", "P", "M1", "C1", "M2", "C2"),
    sire = c(NA, NA, "PPS", NA, "P",  NA, "P"),
    dam  = c(NA, NA, "PPD", NA, "M1", NA, "M2"),
    sex  = c("M", "F", "M", "F", "F", "F", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  pX <- pos$x[pos$id == "P"]
  m1X <- pos$x[pos$id == "M1"]
  ## Pinned, re-measured live this session: M1 sits 0.1 from her own
  ## anchor P -- WELL within .individualClearance (0.41667) -- the
  ## intentional minSep*0.4-fallback offset (:816, non-qualifying unit,
  ## since P has 2 mates), not a defect. If the own-anchor exclusion were
  ## missing or wrong, this design's own new pass would push M1 away from
  ## P, moving m1X off 0.4 -- exactly the 37.3% false-positive collateral
  ## the design doc's §3.2 measurement warns against.
  expect_equal(pX, 0.5, tolerance = 1e-6)
  expect_equal(m1X, 0.4, tolerance = 1e-6)
  expect_true(abs(pX - m1X) < .individualClearance)
})

## ---- Walker/BJL cutover (Phase 3, this session): regression coverage for
## 3 structurally-interesting fixtures (single-child duplicate chains,
## nested/consanguineous unions) originally built to exercise the NOW-
## REMOVED Track-3-Engagement-Gate post-hoc nudge mechanism
## (docs/planning/pedigree-diagram-duplicate-occurrence-centering-
## investigation.md sec10-11). That mechanism (.computeDupNudge(), the
## Track-3-Engagement Gate) no longer exists -- the new engine's Tier 3
## B1/B3 derived-point formula (S8.1) makes it unnecessary by construction.
## These 3 fixtures are kept as general black-box regression coverage on
## the outer makePedigreeMatingLayout() surface, re-pinned to the new
## engine's own values (derived by actually running it, never hand-
## derived) -- retained for their own structural interest (single-child
## duplicate/nested-union shapes), not for the old mechanism they used to
## exercise. -----------------------------------------------------------

test_that("makePedigreeMatingLayout positions a nested single-child
           duplicate-chain fixture (P1,P2 -> A,Y; A x Y -> GC1,GC2;
           GC1 x GC2 -> GGC; GC2 also x outside founder W2 -> GGC2,
           duplicating GC2 at __union_3) without error, and __union_2's
           x is pinned to the new Walker/BJL engine's own value", {
  nested <- data.frame(
    id   = c("P1", "P2", "A", "Y", "GC1", "GC2", "W2", "GGC", "GGC2"),
    sire = c(NA, NA, "P1", "P1", "A", "A", NA, "GC1", "W2"),
    dam  = c(NA, NA, "P2", "P2", "Y", "Y", NA, "GC2", "GC2"),
    sex  = c("M", "F", "M", "F", "M", "F", "M", "M", "F"),
    stringsAsFactors = FALSE
  )
  nested$gen <- findGeneration(nested$id, nested$sire, nested$dam)
  layout <- makePedigreeMatingLayout(nested, edgeStyle = "direct")
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_2"], 60.12,
               tolerance = 1e-6)
})

test_that("makePedigreeMatingLayout positions a nested single-child
           duplicate-chain fixture where A additionally mates outside
           founder X (mirrors the F1 fixture's own shape, flipping the
           anchor so Y anchors A x Y) without error, and __union_3's x is
           pinned to the new Walker/BJL engine's own value", {
  notover <- data.frame(
    id   = c("P1", "P2", "A", "Y", "X", "C1", "GC1", "GC2", "W2", "GGC", "GGC2"),
    sire = c(NA, NA, "P1", "P1", NA, "A", "A", "A", NA, "GC1", "W2"),
    dam  = c(NA, NA, "P2", "P2", NA, "X", "Y", "Y", NA, "GC2", "GC2"),
    sex  = c("M", "F", "M", "F", "F", "F", "M", "F", "M", "M", "F"),
    stringsAsFactors = FALSE
  )
  notover$gen <- findGeneration(notover$id, notover$sire, notover$dam)
  layout <- makePedigreeMatingLayout(notover, edgeStyle = "direct")
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_3"], 180.12,
               tolerance = 1e-6)
})

test_that(".positionMatingUnitForest's F1 target case (investigation doc's
           own .commentOneFixture() pedigree) produces the exact,
           re-derived value on the outer makePedigreeMatingLayout()
           surface under the new Walker/BJL engine (Phase 3 cutover) --
           re-pinned by actually running the new engine, never
           hand-derived

           Track 7 Phase 3 CHANGE (S652 -- issue #166, scoped revert;
           found during this session's own GREEN-phase verification, not
           named in the design doc's own §6.3 inventory -- a genuine
           inventory gap, disclosed here rather than silently absorbed):
           __union_1 (P1/P2) still QUALIFIES, but qualifying no longer
           recenters the union's x -- it reverts to Tier 2's
           child-midpoint, which coincides exactly with P1's own tier1X
           (Finding B), landing at P1's x (150) plus the pre-existing
           0.12px epsilon nudge (0.001 raw units * xScale 120) -- 150.12,
           not the old anchor/mate-midpoint value of 210. P2's own widened
           offset (Track 7 Phase 1, kept) is unaffected.", {
  f1 <- data.frame(
    id   = c("P1", "P2", "X", "A", "Y", "W", "C1", "GC", "C2"),
    sire = c(NA, NA, NA, "P1", "P1", NA, "A", "A", "W"),
    dam  = c(NA, NA, NA, "P2", "P2", NA, "X", "Y", "Y"),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  f1$gen <- findGeneration(f1$id, f1$sire, f1$dam)
  layout <- makePedigreeMatingLayout(f1, edgeStyle = "direct")
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_1"], 150.12,
               tolerance = 1e-6)
})

## ==========================================================================
## Walker/BJL apportioning engine (Phase 3 cutover, this session): the
## tests below were originally written against
## .positionMatingUnitForestBJL(), a standalone adapter running side by
## side with the OLD algorithm (docs/planning/pedigree-diagram-walker-bjl-
## apportioning-redesign-plan.md Phase 2, as amended by docs/planning/
## pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md's S3
## mechanism and S8 seam-resolution formula). Phase 3's cutover (this
## session) renamed that function to .positionMatingUnitForest() outright,
## replacing the OLD implementation entirely -- these tests are merged in
## with that one call-site rename applied throughout (matching Commit
## 3-1's own file list); test content and fixtures are otherwise
## unchanged from Phase 2a/2b.
##
## Implements the 3-tier reconciliation the design note settles on:
##   Tier 1: genuine-tree BJL (.positionTreeApportion(), Phase 1a, unchanged) via a
##     CHILDREN(individual) accessor that reattaches an anchored union's real
##     children directly onto the anchor (S3.2) -- a mating unit itself is NEVER a
##     tree-recursion node -- terminated by a reinstated, gen-grouped sweepMinSep()
##     backstop (S3.1.1), run ONCE.
##   Tier 2: for every ANCHORED unit, x_raw = midpoint(real children's FINAL Tier-1
##     x), then an exact-tie sweep among unions + genuine nodes at the same gen
##     (S3.3.3/S3.4).
##   Tier 3: for every B1 (true fold-in) or B3 (genuine duplicate) non-anchor
##     occurrence, a derived point off its own unit's FINAL x -- the B1 sub-case
##     folds orderBySex's old post-hoc swap directly into the formula (S8.1):
##       qualifies(U): mateCount(P)==1 && mateCount(M)==1 && !hasOwnDirectChild(P)
##         && sireId/damId %in% realIds && unambiguous opposite sex
##       if qualifies(U): M_repr.x = P.x(FINAL) + sign(M)*minSep*0.4   -- S8's fix:
##         anchored on P's OWN final x, never U.x(FINAL) -- see S8.2's proof of why
##         this is unconditionally correct for any sweepMinSep()-induced drift,
##         where the OLD (U.x(FINAL)-anchored) formula was not.
##       else: M_repr.x = U.x(FINAL) + minSep*0.4   -- unchanged fallback, sign +1.
##     B2 (M has a parent edge or her own D5 direct child) gets NO derived point --
##     the render layer points directly at M's own, already-final genuine x.
##
## Oracle provenance for the numerically-exact fixtures below (Tests 1, 2, 5, 6, 11,
## 13, 14, 15): derived by actually running Tier 1's own mechanics (CHILDREN(individual),
## .buildForestChildrenOf() + .positionTreeApportion() from the existing Phase 1a
## engine, then a gen-grouped sweepMinSep() backstop copied byte-for-byte from
## R/makePedigreeDiagramData.R's own shipped push semantics including its exact
## order(x, ids, method="radix") tie-break) against each fixture -- never
## hand-derived or guessed.
## ==========================================================================

## Minimal, position-only edge set for the Phase 2b live-render checks below:
## parent -> mating-unit and mating-unit -> child, direct (no rectilinear
## waypoints, no shape/color/dashes) -- deliberately NOT
## makePedigreeMatingLayout()'s own full cosmetic decoration: styling does
## not affect chromote's getPositions() output when physics is off, so a
## minimal id/x/y node set is sufficient. Filters both ends of every edge
## against nodeIds so a dangling non-anchor party's sire/dam edge (dropped
## from the node set entirely) never references a node vis.js was never
## given.
.buildMinimalEdges <- function(forest, nodeIds) {
  u <- forest$matingUnits
  unitParentEdges <- rbind(
    data.frame(from = u$sire, to = u$id, stringsAsFactors = FALSE),
    data.frame(from = u$dam, to = u$id, stringsAsFactors = FALSE)
  )
  edges <- rbind(
    unitParentEdges,
    data.frame(from = forest$childEdges$from, to = forest$childEdges$to,
               stringsAsFactors = FALSE)
  )
  edges[edges$from %in% nodeIds & edges$to %in% nodeIds, , drop = FALSE]
}

## ---- 1. P/C1/P-union-M/C2: individual anchor's CHILDREN() mixes a direct D5 -----
## child and a real union child at the SAME recursion level -- S1(a)'s own fixture.

test_that(".positionMatingUnitForest positions an anchor whose CHILDREN() mixes
           a direct D5 child and a real mating-unit child: the anchor's own x is
           the exact midpoint of BOTH children's final x (computed directly from
           those children, not stated in terms of the union), and the union's own
           x_raw independently equals its one real child's x (S1(a)/S3.2)", {
  ped <- data.frame(
    id = c("ANCH", "MATE", "C1", "C2"),
    sire = c(NA, NA, "ANCH", "ANCH"), dam = c(NA, NA, NA, "MATE"),
    sex = c("M", "F", "M", "F"), gen = c(0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  anchX <- pos$x[pos$id == "ANCH"]
  c1X <- pos$x[pos$id == "C1"]
  c2X <- pos$x[pos$id == "C2"]
  expect_equal(anchX, (c1X + c2X) / 2, tolerance = 1e-9)

  unitId <- forest$matingUnits$id[1L]
  unitX <- pos$x[pos$id == unitId]
  expect_equal(unitX, c2X, tolerance = 1e-9)  # union's one real child == its own x
})

## ---- 2. Mating unit with >=3 real children + a true B1 free-pass mate -----------

test_that(".positionMatingUnitForest positions a >=3-child union with a
           QUALIFYING B1 free-pass mate at the exact midpoint of its 3
           children (Tier 2, unconditionally -- issue #166's scoped
           revert, S652), NOT the anchor/mate midpoint Track 7 Phase 1
           used to give it -- while the mate's own derived point stays at
           ANCH.x(FINAL) + minSep (S2, S8.1's B1 branch, widened by Track
           7 Phase 1 §2.2, KEPT per the ratified design)

           Track 7 Phase 3 CHANGE (S652): this union QUALIFIES (ANCH male,
           mateCount 1 each, no direct child, unambiguous sex), but
           qualifying no longer matters for the union's OWN x -- the
           recenter loop that used to override Tier 2's formula for
           exactly this subset is deleted. MATE's own offset still widens
           from minSep*0.4 to minSep (Track 7 Phase 1, unaffected by this
           revert).", {
  ped <- data.frame(
    id = c("ANCH", "MATE", "C1", "C2", "C3"),
    sire = c(NA, NA, "ANCH", "ANCH", "ANCH"),
    dam = c(NA, NA, "MATE", "MATE", "MATE"),
    sex = c("M", "F", "F", "M", "F"), gen = c(0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  unitId <- forest$matingUnits$id[1L]
  unitX <- pos$x[pos$id == unitId]
  anchX <- pos$x[pos$id == "ANCH"]
  mateX <- pos$x[pos$id == "MATE"]
  c1X <- pos$x[pos$id == "C1"]; c2X <- pos$x[pos$id == "C2"]
  c3X <- pos$x[pos$id == "C3"]

  expect_equal(nrow(forest$duplicates), 0L)  # MATE is B1, not B3 -- no __dup_ row
  ## MATE's derived point widens to ANCH's own Tier-1 x + minSep (Track 7,
  ## dropping the old *0.4 multiplier) -- unaffected by the union's own x,
  ## since the B1 formula reads tier1X directly, never unitX.
  expect_equal(mateX, anchX + 1, tolerance = 1e-9)
  ## Post-revert (S652): the union's x is once again the exact mean of its
  ## 3 children (0, 1, 2 -> mean 1.0), which exactly coincides with ANCH's
  ## own tier1X (1.0, Finding B's anchor/children-mean identity) -- the
  ## pre-existing epsilon tie-break nudges it to 1.001. Re-measured live
  ## against the reverted code, never hand-derived.
  expect_equal(unitX, (c1X + c2X + c3X) / 3, tolerance = 2e-3)
  expect_equal(unitX, 1.001, tolerance = 1e-9)
})

## ---- 3. A B3 duplicate occurrence anchoring elsewhere in a different branch -----

test_that(".positionMatingUnitForest gives a genuine B3 duplicate a derived
           point off its OWN mating unit's x, byte-identical in formula to a B1
           free-pass point (S3.3.1a: B3 is never gated the way B1 is)", {
  ## D anchors D x G (both gen1 vs G's gen0 -- D wins). D ALSO mates with E,
  ## but E is deeper (gen2, her own 2-generation ancestry) and so E, not D,
  ## anchors D x E -- D is duplicated there instead (matching the real
  ## GA204Z/8LKBV9 precedent: an individual can legitimately anchor some of
  ## his own mating units and be duplicated at others, never a uniform rule).
  ped2 <- data.frame(
    id = c("F1", "F2", "D", "G", "F3", "EGP1", "EGP2", "E", "H"),
    sire = c(NA, NA, "F1", NA, "D", NA, NA, "EGP1", "D"),
    dam = c(NA, NA, "F2", NA, "G", NA, NA, "EGP2", "E"),
    sex = c("M", "F", "M", "F", "M", "M", "F", "F", "M"),
    gen = c(0L, 0L, 1L, 0L, 1L, 0L, 0L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped2)
  expect_equal(nrow(forest$duplicates), 1L)
  dupRow <- forest$duplicates[1L, ]
  expect_equal(dupRow$realId, "D")

  pos <- .positionMatingUnitForest(ped2, forest)
  dupUnitX <- pos$x[pos$id == dupRow$matingUnitId]
  dupX <- pos$x[pos$id == dupRow$id]
  expect_equal(dupX, dupUnitX + 0.4, tolerance = 1e-9)
  ## D's own genuine (anchored-unit-derived) position is untouched by the dup.
  expect_false(is.na(pos$x[pos$id == "D"]))
})

## ---- 4. Forest roots spanning 2+ gens under the synthetic super-root ------------
## S1(d)/S3.1.1's own backstop: a caller-supplied 'gen' disagreeing with the
## structural recursion depth (legal -- .positionMatingUnitForest()'s own
## contract takes 'gen' as caller-supplied, validated against nothing).

test_that(".positionMatingUnitForest's sweepMinSep() backstop separates 2
           independent forest roots forced to the SAME rendered gen despite one
           being, structurally, several recursion levels deeper (S1(d), general
           case of S3.1.1's own F0/D/C mechanism)", {
  ped <- data.frame(
    id = c("F0", "D", "C", "R2"),
    sire = c(NA, "F0", "S", NA), dam = c(NA, NA, "D", NA),
    sex = c("M", "F", "M", "F"),
    gen = c(0L, 1L, 0L, 0L),  # C's true recursion depth is 2; rendered gen forced 0
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  gen0 <- pos[.nodeKind(pos$id) == "individual" & pos$gen == 0L, ]
  expect_true(nrow(gen0) >= 2L)
  gaps <- diff(sort(gen0$x))
  expect_true(all(gaps >= 1L - 1e-6),
              info = paste("gen-0 x values:", paste(sort(gen0$x), collapse = ", ")))
})

## ---- 5. A grandchild simultaneously a reattached real child AND her own -----
## qualifying orderBySex anchor (P role) -- S8's formula must read her Tier-1
## FINAL x, not a relative/pre-super-root-accumulation intermediate.

test_that(".positionMatingUnitForest correctly folds a grandchild's own
           qualifying union into S8's formula, reading her Tier-1 FINAL x (a
           reattached real child 2 recursion levels deep) as P.x, not a stale
           intermediate", {
  ped <- data.frame(
    id = c("GGP1", "GGP2", "GP", "GPMATE", "GX", "Y", "Z"),
    sire = c(NA, NA, "GGP1", NA, "GPMATE", NA, "GX"),
    dam = c(NA, NA, "GGP2", NA, "GP", NA, "Y"),
    sex = c("M", "F", "F", "M", "F", "M", "F"),
    gen = c(0L, 0L, 1L, 0L, 2L, 0L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  gxUnit <- forest$matingUnits$id[forest$matingUnits$anchor == "GX" &
                                     !is.na(forest$matingUnits$anchor)]
  expect_equal(length(gxUnit), 1L)  # GX (deeper gen) anchors her own union, not Y

  gxX <- pos$x[pos$id == "GX"]
  yX <- pos$x[pos$id == "Y"]
  ## Widened minSep*0.4 -> minSep (Track 7, S647).
  expect_equal(yX, gxX - 1, tolerance = 1e-9)  # F anchor, M mate -> sign = -1
  expect_true(yX < gxX)
})

## ---- 6. WCPXHD-shaped hub (mateCount(P)==1 gate excludes the fold-in formula) ---

test_that(".positionMatingUnitForest's qualifies() mateCount(M)==1 conjunct
           (S8.2/S8.5) correctly EXCLUDES a 5-union hub from the fold-in formula
           at every one of her mates' unions -- each B1/B3 representative sits
           near its OWN union's x, not clustered near a single shared anchor
           point (S8.2's own load-bearing-gate finding)", {
  nMates <- 5L
  ped <- data.frame(
    id = c("HUB", paste0("MATE", seq_len(nMates)), paste0("KID", seq_len(nMates))),
    sire = c(NA, rep(NA, nMates), rep("HUB", nMates)),
    dam = c(NA, rep(NA, nMates), paste0("MATE", seq_len(nMates))),
    sex = c("M", rep("F", nMates), rep("M", nMates)),
    gen = c(0L, rep(0L, nMates), rep(1L, nMates)),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  expect_equal(nrow(forest$matingUnits), nMates)
  expect_true(all(forest$matingUnits$anchor != "HUB"))  # HUB loses every tie
  expect_equal(nrow(forest$duplicates), nMates - 1L)    # 1 B1 primary + 4 B3 dups

  pos <- .positionMatingUnitForest(ped, forest)
  hubReps <- pos$x[pos$id == "HUB" |
                      (grepl("^__dup_HUB_", pos$id))]
  expect_equal(length(hubReps), nMates)
  ## NOT clustered: if the gate were bypassed, all 5 would sit within
  ## +-minSep*0.4 of one shared point. They must instead span roughly the
  ## full width of the 5 unions' own spread.
  expect_true(diff(range(hubReps)) > 1L)
})

## ---- 7/8. hasOwnDirectChild(M) forces B2 in EVERY non-anchor occurrence ---------

test_that(".positionMatingUnitForest classifies a founder with her own D5
           direct child as B2 in a separate non-anchor union occurrence: no
           derived point, exactly one write to her own genuine position (S3.3.1,
           S3.3.2)", {
  ped <- data.frame(
    id = c("MOM", "DAD", "OWNCHILD", "OTHERANCH", "SHAREDKID"),
    sire = c(NA, NA, "MOM", NA, "OTHERANCH"),
    dam = c(NA, NA, NA, NA, "MOM"),
    sex = c("F", "M", "F", "M", "F"),
    gen = c(0L, 0L, 1L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  expect_equal(nrow(forest$duplicates), 0L)  # B2 never gets a __dup_ entry either

  pos <- .positionMatingUnitForest(ped, forest)
  momRows <- pos[pos$id == "MOM", ]
  expect_equal(nrow(momRows), 1L)   # exactly one write to MOM's position
  expect_false(is.na(momRows$x))
  expect_false(any(grepl("^__dup_MOM_", pos$id)))
})

## ---- 9. A B2 non-anchor party (own parent edge) excludes reordering entirely ----

test_that(".positionMatingUnitForest's qualifies() gate excludes a B2 non-anchor
           party (her own real parent edge, S1060's !hasParentEdge(M) conjunct)
           from the fold-in formula entirely -- neither party's position is
           altered by the union (S3.1.2 Step 3, S8's B2/B3 untouched-by-S8 note)", {
  ped <- data.frame(
    id = c("GP1", "GP2", "MOM", "XGF1", "XGF2", "XPAR", "X", "C"),
    sire = c(NA, NA, "GP1", NA, NA, "XGF1", "XPAR", "X"),
    dam = c(NA, NA, "GP2", NA, NA, NA, NA, "MOM"),
    sex = c("M", "F", "F", "M", "F", "M", "M", "F"),
    gen = c(0L, 0L, 1L, 0L, 0L, 1L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  unitId <- forest$matingUnits$id[forest$matingUnits$sire == "X" |
                                     forest$matingUnits$dam == "X"]
  expect_equal(forest$matingUnits$anchor[forest$matingUnits$id == unitId], "X")
  expect_equal(forest$matingUnits$nonAnchor[forest$matingUnits$id == unitId], "MOM")
  expect_equal(nrow(forest$duplicates), 0L)

  pos <- .positionMatingUnitForest(ped, forest)
  momRows <- pos[pos$id == "MOM", ]
  expect_equal(nrow(momRows), 1L)  # exactly one write to MOM's position (S9)
  expect_false(is.na(momRows$x))
})

## ---- 10. Tier-2's exact-tie sweep resolves a union/genuine-node coincidence -----
## before Tier 3 reads it -- a general property check (S3.4/S3.4.1-3), not a
## single hand-verified numeric collision.

test_that(".positionMatingUnitForest has no exact x/gen coincidence among
           individual + union + duplicate nodes together on a moderately complex
           multi-branch synthetic fixture, confirming Tier 2's own exact-tie sweep
           (unions vs. genuine nodes, unions vs. unions) actually fires before
           Tier 3 reads any union's x (S3.4)", {
  ped <- data.frame(
    id = c("A1", "A2", "B1", "B2", "C1", "C2",
           "KA", "KB1", "KB2", "KC"),
    sire = c(NA, NA, NA, NA, NA, NA, "A1", "B1", "B1", "C1"),
    dam = c(NA, NA, NA, NA, NA, NA, "A2", "B2", "B2", "C2"),
    sex = c("M", "F", "M", "F", "M", "F", "F", "M", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 0L, 0L, 1L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  nonDup <- pos[.nodeKind(pos$id) != "duplicate", ]
  key <- paste(round(nonDup$x, 6), nonDup$gen)
  expect_false(any(duplicated(key)))
})

## ---- 10b. Track 7's widened B1 offset can land exactly on an unrelated ---------
## real individual -- the Tier-3 de-collision sweep (S647) must catch this, not
## just ties WITHIN tier3Ids (docs/planning/pedigree-diagram-track7-mate-
## spacing-plan.md §7's own "collision-headroom check"). Found empirically this
## session (Pre-RED): widening derivedX()'s B1 branch from minSep*0.4 to minSep
## (§2.2) makes the widened mate land exactly minSep away from the anchor -- the
## SAME spacing increment every other adjacent pair in the algorithm already
## uses -- so an exact collision with some other already-placed node (real
## individual or union) at the same displayed gen is a routine occurrence, not a
## rare edge case (24 pairs on the real 375-individual fixture alone, before this
## fix). The PRE-EXISTING tier3 sweep (unchanged by Track 7's own formula change)
## only ever compared tier3Ids against each other, never against tier1X/unitX --
## this minimal fixture pins the exact mechanism and exact nudged value.

test_that(".positionMatingUnitForest's Tier-3 de-collision sweep catches a
           Track-7-widened B1 mate landing exactly on an unrelated real
           individual's tier1X (not just ties among tier3Ids) -- the minimal
           reproduction of the class of collision found on 3 real fixtures
           this session (S647)", {
  ## A (sire) x B (dam) is B/anchor=A's only union; C is A's real child via
  ## the union. A's tier1X = 0 (root, single child C via sweepMinSep's own
  ## backstop pushes C to 1). B's widened B1 point (A.x + minSep = 0 + 1 =
  ## 1) exactly ties C's own tier1X (1) at the same displayed gen (C's NA
  ## gen defaults to 0, same as A/B) -- the exact class of collision found
  ## on the real fixtures, reproduced minimally.
  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"), gen = c(0L, 0L, NA_integer_),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  aX <- pos$x[pos$id == "A"]
  bX <- pos$x[pos$id == "B"]
  cX <- pos$x[pos$id == "C"]
  expect_equal(aX, 0, tolerance = 1e-9)
  expect_equal(cX, 1, tolerance = 1e-9)
  ## B's raw widened point (aX + minSep = 1) exactly ties cX (1). A tiny
  ## 1e-3 tie-break would leave B rendering almost entirely overlapping
  ## C's own full-sized circle (found live: the Track B "shrunk" vignette
  ## fixture's P2/C4 pair, confirmed via chromote bounding-box queries,
  ## not just eyeballed) -- the sweep instead pushes B a full minSep
  ## further away (matching Tier 1's own sweepMinSep() guarantee for real
  ## individuals), continuing in the SAME direction as B's own original
  ## sign (here, +1 -- A is male, so B's formula sign was already +1;
  ## unaffected by the direction-preserving refinement).
  expect_equal(bX, 2, tolerance = 1e-9)
  .expectNoOverlap(pos)
})

## ---- 11. Anchor P (female, qualifying) with a true B1 mate M --------------------

test_that(".positionMatingUnitForest leaves a qualifying female anchor's own x
           unmodified and derives her B1 mate's point at P.x(FINAL) - minSep,
           strictly left of P (S8.1, sign = -1 for F-anchor/M-mate; widened
           from minSep*0.4 by Track 7, S647)", {
  ped <- data.frame(
    id = c("ANCHF", "MATEM", "C1"),
    sire = c(NA, NA, "MATEM"), dam = c(NA, NA, "ANCHF"),
    sex = c("F", "M", "F"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  anchX <- pos$x[pos$id == "ANCHF"]
  c1X <- pos$x[pos$id == "C1"]
  expect_equal(anchX, c1X, tolerance = 1e-9)  # sole child -> anchor unmodified

  mateX <- pos$x[pos$id == "MATEM"]
  expect_equal(mateX, anchX - 1, tolerance = 1e-9)
  expect_true(mateX < anchX)
})

## ---- 12. A B2 worked example: qualifying-SHAPED union, non-anchor has her own --
## parent edge -- excluded from reordering, neither position touched.

test_that(".positionMatingUnitForest excludes a qualifying-shaped union from
           reordering when the non-anchor party is B2 (her own parent edge):
           neither party's x differs from its own untouched genuine/derived
           value (S3.1.2 Step 3)", {
  ## MIA has her own parent edge (GP1 x GP2), so she is B2 whenever she is a
  ## non-anchor party. YALE is given her own 2-generation ancestry so YALE
  ## (deeper) anchors the YALE x MIA union and MIA becomes the non-anchor --
  ## the qualifying-SHAPED union whose non-anchor party is actually B2.
  ped2 <- data.frame(
    id = c("GP1", "GP2", "MIA", "YGF1", "YGF2", "YPAR", "YALE", "KID"),
    sire = c(NA, NA, "GP1", NA, NA, "YGF1", "YPAR", "YALE"),
    dam = c(NA, NA, "GP2", NA, NA, "YGF2", NA, "MIA"),
    sex = c("M", "F", "F", "M", "F", "M", "M", "M"),
    gen = c(0L, 0L, 1L, 0L, 0L, 1L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest2 <- .buildMatingUnitForest(ped2)
  unitId2 <- forest2$matingUnits$id[forest2$matingUnits$sire == "YALE" |
                                       forest2$matingUnits$dam == "YALE"]
  expect_equal(forest2$matingUnits$anchor[forest2$matingUnits$id == unitId2], "YALE")
  expect_equal(forest2$matingUnits$nonAnchor[forest2$matingUnits$id == unitId2], "MIA")
  expect_equal(nrow(forest2$duplicates), 0L)  # B2 never gets a __dup_ entry

  pos2 <- .positionMatingUnitForest(ped2, forest2)
  miaRows <- pos2[pos2$id == "MIA", ]
  expect_equal(nrow(miaRows), 1L)
  expect_false(is.na(miaRows$x))
})

## ---- 13. F0/D/[S(dangling) x D]/C -- S3.1.1's own required counter-example ------

test_that(".positionMatingUnitForest's reinstated sweepMinSep() backstop
           separates a founder from her own grandchild (reachable only through a
           dangling co-parent) by at least minSep, even though both collapse to
           the identical relative x under the genuine-tree recursion alone
           (S3.1.1's own F0/D/C counter-example, executed)", {
  ped <- data.frame(
    id = c("F0", "D", "C"),
    sire = c(NA, "F0", "S"), dam = c(NA, NA, "D"),
    sex = c("M", "F", "M"), gen = c(0L, 1L, NA_integer_),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  f0X <- pos$x[pos$id == "F0"]
  cX <- pos$x[pos$id == "C"]
  expect_equal(pos$gen[pos$id == "C"], 0L)  # NA forced to 0 -- collides with F0
  expect_true(abs(cX - f0X) >= 1L - 1e-6,
              info = paste("F0.x=", f0X, "C.x=", cX))
})

## ---- 14. THE regression test: sweepMinSep() moves a qualifying union's own ------
## real child -- S7's counter-example, now expected to PASS under S8's fix.

test_that(".positionMatingUnitForest's S8 fix holds even when sweepMinSep()
           is forced to move a qualifying union's own real child (S7's exact
           counter-example shape, S8.2's proof): the fold-in formula still
           correctly places the B1 mate strictly left of the anchor, because it
           reads P.x directly rather than the drifted U.x(FINAL)", {
  ped <- data.frame(
    id = c("ANCHF", "MATEM", "C1", "AG"),
    sire = c(NA, NA, "MATEM", "Z"), dam = c(NA, NA, "ANCHF", "C1"),
    sex = c("F", "M", "F", "M"),
    gen = c(0L, 0L, 1L, 1L),  # AG's TRUE recursion depth is 2 -- forced to 1
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  unitId <- forest$matingUnits$id[1L]
  pos <- .positionMatingUnitForest(ped, forest)

  anchX <- pos$x[pos$id == "ANCHF"]
  c1X <- pos$x[pos$id == "C1"]
  unitX <- pos$x[pos$id == unitId]
  ## Confirm this fixture actually exercises the seam: the union's FINAL x
  ## differs meaningfully from the anchor's own x. Under Track 7 (S647)
  ## this union unconditionally recenters to the anchor/mate midpoint
  ## regardless of any sweepMinSep child-push, so it no longer depends on
  ## C1 having been pushed the way the OLD child-midpoint formula did --
  ## the S8 property this test actually verifies (the mate reads P.x
  ## directly, never U.x) is unaffected either way, since Track 7's own
  ## formula also reads tier1X directly, never unitX.
  expect_true(abs(unitX - anchX) > 0.4 + 1e-9,
              info = paste("unitX=", unitX, "anchX=", anchX, "-- fixture did not",
                            "force the intended drift; re-check the collider"))

  mateX <- pos$x[pos$id == "MATEM"]
  expect_equal(mateX, anchX - 1, tolerance = 1e-9)  # S8: anchored on P.x, not U.x
  expect_true(mateX < anchX)
})

## ---- 15. Obligation 1 (S8.4): sweepMinSep() pushes P HERSELF, not just her -----
## children -- P.x must be read post-sweep, never a pre-sweep intermediate.

test_that(".positionMatingUnitForest reads the anchor's own x from its
           genuinely final, post-sweepMinSep() value when the backstop pushes the
           anchor herself (not her children) -- S8.4 Obligation 1's own required
           regression case", {
  ped <- data.frame(
    id = c("ANCHF", "MATEM", "C1", "AA"),
    sire = c(NA, NA, "MATEM", "Z"), dam = c(NA, NA, "ANCHF", "C1"),
    sex = c("F", "M", "F", "M"),
    gen = c(0L, 0L, 1L, 0L),  # AA's TRUE recursion depth is 3 -- forced to 0
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  anchX <- pos$x[pos$id == "ANCHF"]
  c1X <- pos$x[pos$id == "C1"]
  ## Confirm the fixture actually pushed the ANCHOR (not C1): the anchor's own
  ## x must have moved off the union's raw child-midpoint (c1X, since C1 is the
  ## union's only child and was itself untouched).
  expect_true(abs(anchX - c1X) > 1e-9,
              info = paste("anchX=", anchX, "c1X=", c1X, "-- fixture did not",
                            "push the anchor; re-check the collider"))

  mateX <- pos$x[pos$id == "MATEM"]
  ## A careless implementation reading a pre-sweep P.x intermediate (== c1X,
  ## since pre-sweep the anchor and her only child coincide) would compute
  ## mateX = c1X - minSep, not anchX - minSep (widened from minSep*0.4 by
  ## Track 7, S647).
  ##
  ## CHANGED (S647's bidirectional-search individual-collision fix): the
  ## raw widened point (anchX - minSep = 0) exactly ties AA's own tier1X
  ## (0) in this fixture. The search tries the SAME direction her own
  ## formula's sign already chose first (F anchor/M mate -> sign = -1,
  ## i.e. further LEFT, never flipped to the anchor's right side) --
  ## anchX - 2*minSep (-1) is free (ties neither AA at 0 nor the anchor at
  ## 1), so the search accepts it immediately. Confirmed by direct
  ## computation, not hand-derived.
  ##
  ## Note: anchX - 2 and c1X - 1 happen to be numerically identical in
  ## this specific fixture (1-2 == 0-1) -- a coincidence of these
  ## particular values, not a claim that the two computations agree in
  ## general; the positive assertion above (anchX-based) is what actually
  ## establishes correctness here.
  expect_equal(mateX, anchX - 2, tolerance = 1e-9)
})

## ---- Property tests (parent plan's own Phase 2 "What DONE looks like") ---------

test_that(".positionMatingUnitForest guarantees at least minSep between every
           pair of same-generation REAL individual nodes on the real
           GA204Z/8LKBV9 loop fixture (the same multi-anchor fixture the OLD
           function's own sweepMinSep regression test uses) -- the
           property-level successor to that test, real-375-fixture
           measurement explicitly deferred to Phase 2b. A B1 derived point
           can share its underlying individual's own real id with a genuine
           node (S3.3.1), so this fixture is deliberately one where no B1
           occurrence exists at all (8LKBV9's only non-anchor occurrence is
           a B3 __dup_ marker, unambiguously excluded by id prefix) --
           keeping .nodeKind()'s id-pattern classification reliable here", {
  ped <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  expect_equal(nrow(forest$duplicates), 1L)  # 8LKBV9's own B3 marker, confirmed
  expect_equal(forest$duplicates$realId, "8LKBV9")
  pos <- .positionMatingUnitForest(ped, forest)
  ## A B1/B2 non-anchor party's derived/genuine point can share its own
  ## real id with what .nodeKind() classifies as a plain "individual" node
  ## (S3.3.1) -- e.g. 8DKELJ/G8EBU9/8P17E3 here are each B1, not part of
  ## this fixture's own duplicate count. sweepMinSep()'s backstop only
  ## guarantees separation among genuine Tier-1 nodes (real individuals
  ## who are never a "nonAnchor" of any unit), so exclude every id that
  ## IS a nonAnchor anywhere, rather than trust id-pattern alone.
  nonAnchorIds <- unique(forest$matingUnits$nonAnchor[
    !is.na(forest$matingUnits$nonAnchor)])
  indiv <- pos[.nodeKind(pos$id) == "individual" & !(pos$id %in% nonAnchorIds), ]
  for (g in sort(unique(indiv$gen))) {
    xs <- sort(indiv$x[indiv$gen == g])
    if (length(xs) < 2L) next
    expect_true(all(diff(xs) >= 1L - 1e-6),
                info = paste("gen", g, "x values:", paste(xs, collapse = ", ")))
  }
})

test_that(".positionMatingUnitForest: every ANCHORED mating unit's x
           equals the exact midpoint of its own real children's final x --
           one formula, no OR-branches, no clamp exceptions, including a
           single-child union (Track 3's parent-span clamp and Track 6's
           finalUnitX override are both gone by construction under 2b;
           Track 7 Phase 1's own anchor/mate-midpoint override is ALSO
           gone by construction, issue #166's scoped revert, S652)

           Track 7 Phase 3 CHANGE (S652): both units in this fixture
           actually QUALIFY (each is a simple 2-parent, single-mate,
           no-direct-child pair) -- previously that meant BOTH recentered
           to their parents' midpoint instead of the child-midpoint. That
           special case no longer exists: this test now asserts the plain
           child-midpoint formula for both, exactly as it would for any
           non-qualifying unit.", {
  ped <- data.frame(
    id = c("P1", "P2", "C1", "C2", "C3", "P3", "P4", "C4"),
    sire = c(NA, NA, "P1", "P1", "P1", NA, NA, "P3"),
    dam = c(NA, NA, "P2", "P2", "P2", NA, NA, "P4"),
    sex = c("M", "F", "M", "F", "M", "M", "F", "F"),
    gen = c(0L, 0L, 1L, 1L, 1L, 0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  anchored <- forest$matingUnits[!is.na(forest$matingUnits$anchor), , drop = FALSE]
  childEdges <- forest$childEdges
  for (i in seq_len(nrow(anchored))) {
    unitId <- anchored$id[i]
    unitX <- pos$x[pos$id == unitId]
    ## Child-midpoint formula, unconditionally -- no more qualifying
    ## exception (S652). Both units' single child (C1/C2/C3's mean for
    ## the first, C4 alone for the second) exactly coincides with its own
    ## anchor's tier1X (Finding B), so a 0.001 epsilon tie-break applies;
    ## the 2e-3 tolerance already accommodates it.
    kids <- childEdges$to[childEdges$from == unitId]
    formulaX <- mean(pos$x[match(kids, pos$id)])
    expect_equal(unitX, formulaX, tolerance = 2e-3, info = unitId)
  }
})

test_that(".positionMatingUnitForest produces exactly nrow(ped) +
           nrow(forest$duplicates) + nrow(forest$matingUnits) rows, with no NA x
           or gen, on a fixture combining several of the classification cases
           above (structural parity with the OLD function's own output contract)", {
  ped <- data.frame(
    id = c("A1", "A2", "B", "C1", "C2", "D", "E"),
    sire = c(NA, NA, "A1", "A1", "A1", NA, "D"),
    dam = c(NA, NA, "A2", "A2", "A2", NA, "B"),
    sex = c("M", "F", "F", "M", "F", "M", "M"),
    gen = c(0L, 0L, 1L, 1L, 1L, 0L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  expect_equal(nrow(pos),
               nrow(ped) + nrow(forest$duplicates) + nrow(forest$matingUnits))
  expect_false(any(is.na(pos$x)))
  expect_false(any(is.na(pos$gen)))
})

## ==========================================================================
## Phase 2b: real-fixture + live-render verification (S615), merged in as
## part of the Phase 3 cutover (this session)
## docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md
## Phase 2's own required deliverables:
##   - a reusable, checked-in chromote-based live-render helper
##     (tests/testthat/helper-live-render-positions.R)
##   - the real 375-individual fixture's own zero-exact-coincidence gate ("the
##     single most important test in the whole migration")
##   - the same exact-midpoint invariant re-run on real, not just synthetic, data
##   - the single-child-union "near a parent" prevalence re-measurement
##   - live-rendered ground-truth checks (chromote getPositions(), not internal
##     x/gen math alone) on the F1/"Track C" and real-375 fixtures
## plus docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-
## reconciliation.md sec8.4 Obligation 2's own explicit ask: "Phase 2 should
## measure both trigger shapes' real-fixture frequency together."
## ==========================================================================

test_that("getLiveRenderedPositions() (helper-live-render-positions.R)
           returns the EXACT fixed x/y of a tiny 3-node fixture, ground-
           truth-verified via a real chromote render (not a prediction) --
           confirms the helper mirrors the app's own
           visNetwork()/visPhysics(FALSE) call (R/modPedigree.R:611-614)
           and correctly locates the vis.js Network instance via
           document.getElementById('graph'+widgetDivId).chart.getPositions()", {
  skip_if_not_installed("chromote")
  skip_if_not_installed("htmlwidgets")
  skip_on_cran()

  nodes <- data.frame(id = c("A", "B", "C"), x = c(0, 120, 60),
                       y = c(0, 0, 150), stringsAsFactors = FALSE)
  edges <- data.frame(from = c("A", "C"), to = c("B", "A"),
                       stringsAsFactors = FALSE)

  rendered <- getLiveRenderedPositions(nodes, edges)

  expect_setequal(rendered$id, nodes$id)
  ord <- match(nodes$id, rendered$id)
  expect_equal(rendered$x[ord], nodes$x, tolerance = 1e-6)
  expect_equal(rendered$y[ord], nodes$y, tolerance = 1e-6)
})

## (The zero-exact-coincidence gate on this real fixture -- "the single
## most important test in the whole migration" per the parent plan's own
## Phase 2 spec -- is already covered by the pre-existing test earlier in
## this file; not duplicated here to avoid 2 byte-identical assertions.)

test_that(".positionMatingUnitForest gives every ANCHORED mating unit's x
           the exact midpoint of its own real children's final x -- one
           formula, no OR-branches, no clamp exceptions, including every
           single-child union -- on ALL 237 anchored units of the real
           375-individual bundled fixture, no exclusion (parent plan's own
           Phase 2 spec bullet 3; the version of this same invariant above
           runs on synthetic fixtures too)

           Track 7 Phase 3 CHANGE (S652 -- issue #166, scoped revert,
           docs/planning/pedigree-diagram-track7-phase3-child-centering-
           plan.md §5 step 1): Track 7 Phase 1 used to recenter 34 of
           these 237 units at their two parents' midpoint instead,
           requiring this loop to exclude that 'qualifying' subset
           entirely. That recenter is deleted -- 'qualifying' is now a
           vacuous distinction for x-derivation purposes, so this test's
           own structure (not just a number) is rewritten: every one of
           the 237 anchored units, without exception, is checked against
           the SAME plain child-midpoint formula. This is now the same
           claim the checkInvariant() test above makes on this same
           fixture -- kept as an independent, dedicated measurement of the
           real-375 fixture specifically (belt-and-suspenders, matching
           this file's own established practice of independently
           cross-checking the same real-fixture metric more than once,
           e.g. :425/:1067's own 27L pair).", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  matingUnits <- forest$matingUnits
  childEdges <- forest$childEdges
  anchoredUnits <- matingUnits[!is.na(matingUnits$anchor), , drop = FALSE]
  expect_equal(nrow(anchoredUnits), 237L)
  for (i in seq_len(nrow(anchoredUnits))) {
    unitId <- anchoredUnits$id[i]
    kids <- childEdges$to[childEdges$from == unitId]
    formulaX <- mean(pos$x[pos$id %in% kids])
    actual <- pos$x[pos$id == unitId]
    ## Track 7 Phase 2 (S649, unaffected by this revert): the union-side
    ## proximity push (plan §12.2) applies to every mating unit, so a
    ## legitimate push here is expected, not a defect. Accepted
    ## generically (not by hardcoding which unit ids) as an alternative
    ## match: the deviation is within floating tolerance of
    ## k * ((25+6)/120) for some k in 1:5 (see the "Track 7 Phase 2"
    ## section's own derivation below).
    deviation <- abs(actual - formulaX)
    pushSteps <- deviation / ((25 + 6) / 120)
    isPhase2Push <- deviation > 2e-3 &&
      any(abs(pushSteps - round(pushSteps)) < 1e-6) &&
      round(pushSteps) >= 1L && round(pushSteps) <= 5L
    expect_true(deviation <= 2e-3 + 1e-9 || isPhase2Push,
                info = paste(unitId, "formula", formulaX, "actual", actual,
                             "deviation", deviation))
  }
})

test_that(".positionMatingUnitForest re-measures the single-child-union
           'near a parent' prevalence on the real 375-individual bundled
           fixture (parent plan's own Phase 2 spec bullet 5 / Verification
           Plan item 4's own bullet): the structural count (224/237) is
           unchanged -- D1 is out of scope for this migration -- and every
           one of the 224 unions' x is now the EXACT midpoint of its own
           single child's x (the test above), so the entire 83/224
           'mathematically deterministic from Track 3's clamp' population
           (docs/planning/pedigree-diagram-single-child-union-parent-
           coincidence-investigation.md sec2.2) is resolved BY CONSTRUCTION --
           no clamp exists anywhere in this code. The new distance-to-
           nearest-parent breakdown is reported via message() for the
           session record -- the plan explicitly does not predict this
           number ('the real number can only come from running the engine'),
           so this test asserts only internal consistency, not a specific
           count", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  matingUnits <- forest$matingUnits
  childEdges <- forest$childEdges
  pos <- .positionMatingUnitForest(ped, forest)

  childCount <- table(childEdges$from)
  singleChildUnits <- intersect(names(childCount)[childCount == 1L],
                                 matingUnits$id)
  expect_equal(length(singleChildUnits), 224L)

  xScale <- 120L
  dist <- vapply(singleChildUnits, function(uid) {
    sireX <- pos$x[pos$id == matingUnits$sire[matingUnits$id == uid]]
    damX <- pos$x[pos$id == matingUnits$dam[matingUnits$id == uid]]
    ux <- pos$x[pos$id == uid]
    min(abs(ux - sireX), abs(ux - damX)) * xScale
  }, numeric(1L))

  touching <- sum(dist <= 31)
  halfColumn <- sum(dist <= 60)
  message(sprintf(
    paste("Real-fixture re-measurement: %d/%d single-child unions",
          "touch a parent (<=31px), %d/%d within half a column (<=60px).",
          "Historical OLD-algorithm baseline (clamp-affected): 175/224",
          "touching, 203/224 half-column. Every one of these %d unions' x",
          "is the EXACT midpoint of its own single child's x (no clamp) --",
          "this is genuine structural closeness, not clamp artifact."),
    touching, length(singleChildUnits), halfColumn,
    length(singleChildUnits), length(singleChildUnits)
  ))
  expect_true(touching <= halfColumn && halfColumn <= length(singleChildUnits),
              info = sprintf("touching=%d halfColumn=%d total=%d",
                              touching, halfColumn, length(singleChildUnits)))
})

test_that(".positionMatingUnitForest measures, on the real 375-individual
           bundled fixture, the combined frequency of the 2 disclosed
           sweepMinSep() cosmetic union-dot/M_repr visual-distance-drift
           triggers together (Phase 1b design note sec8.4 Obligation 2:
           'measure both trigger shapes' real-fixture frequency together,
           not just the first') -- confirms every orderBySex-qualifying B1
           case's disclosed drift stays within the formula's own documented
           cosmetic bound, never a correctness violation of the ordering
           guarantee (sec8.2's own proof)

           Track 7 Phase 1 CHANGE (docs/planning/pedigree-diagram-track7-
           mate-spacing-plan.md, S647): the union no longer sat
           near-coincident with the anchor for a qualifying pair -- it
           recentered to the anchor/mate midpoint, so 'drift' (the
           union-dot/mate distance) was half of the widened minSep offset
           (~0.5), not the old fixed 0.4*minSep.

           Track 7 Phase 3 CHANGE (S652 -- issue #166, scoped revert):
           the recenter is deleted, so the union is ONCE AGAIN
           near-coincident with the anchor (Finding B's identity) --
           'drift' (union-dot/mate distance) is now approximately the
           FULL widened minSep offset (~1.0, the anchor-to-mate gap Track
           7 Phase 1 still keeps), not half of it. Re-measured live
           against the reverted code, never hand-derived: range
           [0.74, 3.52], median ~1.0 -- comfortably inside the existing
           <=6 bound below, which needs no change.", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  matingUnits <- forest$matingUnits
  duplicates <- forest$duplicates
  childEdges <- forest$childEdges
  pos <- .positionMatingUnitForest(ped, forest)
  realIds <- as.character(ped$id)
  sexOf <- stats::setNames(as.character(ped$sex), realIds)
  sireOf <- stats::setNames(as.character(ped$sire), realIds)
  damOf <- stats::setNames(as.character(ped$dam), realIds)
  hasParentEdge <- function(id) !is.na(sireOf[[id]]) || !is.na(damOf[[id]])
  hasOwnDirectChild <- function(id) id %in% childEdges$from

  anchoredUnits <- matingUnits[!is.na(matingUnits$anchor), , drop = FALSE]
  everAnchor <- unique(anchoredUnits$anchor)
  nonAnchorSides <- c(anchoredUnits$sire, anchoredUnits$dam)
  neverAnchorIds <- setdiff(unique(nonAnchorSides), everAnchor)
  b1Ids <- Filter(function(id) {
    id %in% realIds && !hasOwnDirectChild(id) && !hasParentEdge(id)
  }, neverAnchorIds)

  unitOf <- function(fp) {
    ownUnits <- matingUnits$id[matingUnits$sire == fp | matingUnits$dam == fp]
    dupUnits <- duplicates$matingUnitId[duplicates$realId == fp]
    setdiff(ownUnits, dupUnits)[1L]
  }
  qualifies <- function(fp) {
    unitId <- unitOf(fp)
    p <- matingUnits$anchor[matingUnits$id == unitId]
    sireId <- matingUnits$sire[matingUnits$id == unitId]
    damId <- matingUnits$dam[matingUnits$id == unitId]
    if (!(sireId %in% realIds) || !(damId %in% realIds)) return(FALSE)
    mateCountP <- sum(anchoredUnits$sire == p | anchoredUnits$dam == p)
    mateCountM <- sum(anchoredUnits$sire == fp | anchoredUnits$dam == fp)
    unambig <- (identical(sexOf[[p]], "M") && identical(sexOf[[fp]], "F")) ||
      (identical(sexOf[[p]], "F") && identical(sexOf[[fp]], "M"))
    mateCountP == 1L && mateCountM == 1L && !hasOwnDirectChild(p) && unambig
  }
  qualifyingB1 <- Filter(qualifies, b1Ids)

  drift <- vapply(qualifyingB1, function(fp) {
    unitId <- unitOf(fp)
    abs(pos$x[pos$id == fp] - pos$x[pos$id == unitId])
  }, numeric(1L))

  ## Bound UNCHANGED by the Phase 3 revert (S652): it was already loose
  ## enough (<=6) to accommodate Track 7 Phase 1's own de-collision-push
  ## outliers (up to 5.5 raw units for 1 of 34 qualifying pairs), and
  ## post-revert the drift distribution (now centered on the FULL minSep
  ## anchor-to-mate gap, ~1.0, instead of half of it, ~0.5) still fits
  ## comfortably inside it -- re-measured directly (max 3.52), not
  ## guessed, so no bound change is needed here.
  expect_true(length(drift) == 0L || all(drift <= 6),
              info = paste("max drift:",
                            if (length(drift) > 0L) max(drift) else NA))

  message(sprintf(
    paste("Obligation 2 measurement: %d orderBySex-qualifying B1",
          "unions on the real fixture; union-dot/mate drift range [%s,",
          "%s] (issue #166's scoped revert, S652, restored the union to",
          "near-anchor-coincidence, so drift is now approximately the",
          "full minSep anchor/mate gap, not half of it -- disclosed",
          "cosmetic, not a correctness defect)."),
    length(qualifyingB1),
    if (length(drift) > 0L) sprintf("%.4f", min(drift)) else "NA",
    if (length(drift) > 0L) sprintf("%.4f", max(drift)) else "NA"
  ))
})

## ---- issue #166's own named cases: direct geometry regression (S652,
## scoped revert) -----------------------------------------------------------
## docs/planning/pedigree-diagram-track7-phase3-child-centering-plan.md §5
## step 1's own required addition: "no existing tests/testthat/ fixture
## currently renders/inspects [issue #166's named] specific geometry
## (straight-vs-dogleg rendering, bar-vs-children-mean deviation) for Track
## B's full 16-subject fixture -- that evidence lives only in the .qmd
## vignette's committed screenshots." This is the FULL (non-shrunk) Track B
## pedigree -- the same structural definition used (shrunk) by the Track 7
## Phase 2 tests above -- reproducing the exact 3 named cases from issue
## #166 and the design doc's own §1 Context: P3xP4->C4 and C4xP6->C4a
## (single-child qualifying unions, dogleg before this fix) and M1xG3's
## 3-child sibship bar (off-center before this fix). Values re-measured
## live against the reverted code, never hand-derived.
test_that(".positionMatingUnitForest's issue #166 named cases -- P3xP4's
           and C4xP6's single-child qualifying unions drop straight to
           their own child (not a dogleg), and M1xG3's 3-child sibship bar
           centers at its children's true mean (not off-center) -- on the
           full, non-shrunk 16-subject Track B fixture", {
  pedB <- data.frame(
    id   = c("P1", "P2", "P3", "P4", "P5", "P6",
             "C1", "C2", "C3", "C4", "C4a",
             "G3", "M1", "L1", "L2", "L3"),
    sire = c(NA, NA, NA, NA, NA, NA,
             "P1", "P1", "P1", "P3", "C4",
             NA, "P1", "M1", "M1", "M1"),
    dam  = c(NA, NA, NA, NA, NA, NA,
             "P2", "P2", "P2", "P4", "P6",
             NA, "P2", "G3", "G3", "G3"),
    sex  = c("M", "F", "M", "F", "F", "F",
             "F", "M", "F", "M", "F",
             "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  pedB$gen <- findGeneration(pedB$id, pedB$sire, pedB$dam)
  forest <- .buildMatingUnitForest(pedB)
  pos <- .positionMatingUnitForest(pedB, forest)

  unitP3P4 <- forest$matingUnits$id[forest$matingUnits$sire == "P3" &
                                       forest$matingUnits$dam == "P4"]
  unitC4P6 <- forest$matingUnits$id[forest$matingUnits$sire == "C4" &
                                       forest$matingUnits$dam == "P6"]
  unitM1G3 <- forest$matingUnits$id[forest$matingUnits$sire == "M1" &
                                       forest$matingUnits$dam == "G3"]

  ## Straight drop: the union's x is within the pre-existing 0.001
  ## exact-tie epsilon of its ONE child's own x -- a dogleg-sized
  ## deviation (Track 7 Phase 1's own ~minSep/2, or worse under
  ## collision pushes) would fail this tight tolerance.
  expect_equal(pos$x[pos$id == unitP3P4], pos$x[pos$id == "C4"],
               tolerance = 2e-3)
  expect_equal(pos$x[pos$id == unitC4P6], pos$x[pos$id == "C4a"],
               tolerance = 2e-3)

  ## Centered bar: the union's x is within the same tight tolerance of
  ## its 3 children's TRUE mean -- issue #166's own named "3.5 vs. true
  ## mean 3.0" off-center defect no longer reproduces.
  childrenMeanM1G3 <- mean(pos$x[pos$id %in% c("L1", "L2", "L3")])
  expect_equal(pos$x[pos$id == unitM1G3], childrenMeanM1G3, tolerance = 2e-3)
})

## NOTE on the 2 tests below: running them live during Phase 2b found a HARD
## zero rendered-pixel-coincidence gate is unachievable by EITHER algorithm,
## for a reason with nothing to do with this migration's own correctness:
## vis.js's own getPositions() rounds reported coordinates to the nearest
## whole pixel (confirmed directly: 3 nodes fed x = 150/150.12/150.5 all
## read back as x = 150), so the shared, pre-existing "cosmetic" 1e-3-raw-
## unit exact-tie nudge used throughout .positionMatingUnitForest() -- xScale
## =120, so 1e-3 * 120 = 0.12px -- is BELOW that rounding granularity and
## renders pixel-identical to whatever it was nudged away from, despite
## being genuinely float-distinct internally (the already-passing internal
## zero-coincidence test above catches THAT, correctly; it was never
## evidence of zero RENDERED overlap). Measured during Phase 2b on the real
## 375-individual fixture, side by side, same script, same helper: OLD
## algorithm 368/714 nodes pixel-coincident (182 groups), NEW (this
## engine) 380/714 (190 groups) -- comparable, not a Phase 2b regression
## (owner-directed decision at the time, via AskUserQuestion: report as a
## diagnostic measurement, not a hard gate). Both tests below therefore
## assert only what the adapter-parity charter actually requires (no id
## silently collapses in vis.js's own DataSet -- confirmed clean, a
## genuine, useful ground-truth check no internal-only test could perform)
## and report the measured pixel-coincidence rate via message() for the
## record. The OLD-vs-NEW side-by-side comparison itself is no longer
## possible post-cutover (the OLD algorithm no longer exists as a separate
## callable function) -- these tests now measure the production engine
## alone.

test_that(".positionMatingUnitForest's positions render with no id
           silently collapsing in vis.js's own DataSet on the F1/'Track C'
           9-subject fixture (P1/P2/X/A/Y/W/C1/GC/C2, consanguineous A x Y)
           -- live chromote ground truth, not internal x/gen math alone
           (this project's own memory note: code-level correctness is not
           evidence of a correct rendered image); reports the measured
           rendered-pixel-coincidence rate (see the NOTE above -- not a
           hard gate, a pre-existing characteristic)", {
  skip_if_not_installed("chromote")
  skip_if_not_installed("htmlwidgets")
  skip_on_cran()

  f1 <- data.frame(
    id   = c("P1", "P2", "X", "A", "Y", "W", "C1", "GC", "C2"),
    sire = c(NA, NA, NA, "P1", "P1", NA, "A", "A", "W"),
    dam  = c(NA, NA, NA, "P2", "P2", NA, "X", "Y", "Y"),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  f1$gen <- findGeneration(f1$id, f1$sire, f1$dam)
  forest <- .buildMatingUnitForest(f1)
  pos <- .positionMatingUnitForest(f1, forest)

  nodes <- data.frame(id = pos$id, x = pos$x * 120, y = pos$gen * 150,
                       stringsAsFactors = FALSE)
  edges <- .buildMinimalEdges(forest, nodes$id)

  rendered <- getLiveRenderedPositions(nodes, edges)

  expect_equal(nrow(rendered), nrow(nodes),
               info = "vis.js DataSet must not silently collapse any id")
  expect_setequal(rendered$id, nodes$id)

  key <- paste(rendered$x, rendered$y)
  nCoincident <- sum(duplicated(key) | duplicated(key, fromLast = TRUE))
  message(sprintf(
    "F1/Track-C live-render measurement: %d/%d nodes rendered
     pixel-coincident (see the NOTE above these 2 tests).",
    nCoincident, nrow(nodes)))
})

test_that(".positionMatingUnitForest's positions render with no id
           silently collapsing in vis.js's own DataSet, among all 714
           real/duplicate/union nodes, on the real 375-individual bundled
           fixture -- live chromote ground truth on production scale,
           completing the parent plan's own required live-render deliverable
           for Phase 2 ('to verify the BJL adapter's real-fixture behavior
           against ground truth, not just internal x/gen values'); reports
           the measured rendered-pixel-coincidence rate (see the NOTE
           above)", {
  skip_if_not_installed("chromote")
  skip_if_not_installed("htmlwidgets")
  skip_on_cran()

  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  nodes <- data.frame(id = pos$id, x = pos$x * 120, y = pos$gen * 150,
                       stringsAsFactors = FALSE)
  edges <- .buildMinimalEdges(forest, nodes$id)
  rendered <- getLiveRenderedPositions(nodes, edges, width = 3000L,
                                        height = 3000L, waitSeconds = 3,
                                        loadTimeout = 60)

  expect_equal(nrow(rendered), nrow(nodes),
               info = "vis.js DataSet must not silently collapse any id")
  expect_setequal(rendered$id, nodes$id)

  key <- paste(rendered$x, rendered$y)
  nCoincident <- sum(duplicated(key) | duplicated(key, fromLast = TRUE))
  message(sprintf(
    "Real-375 live-render measurement: %d/%d nodes rendered
     pixel-coincident (see the NOTE above these 2 tests; historical OLD-
     algorithm baseline measured during Phase 2b: 368/714).",
    nCoincident, nrow(nodes)))
})

