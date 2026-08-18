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

## Track 3 update (docs/planning/pedigree-diagram-same-row-collision-
## avoidance-plan.md sec2.3/sec6 Session C, GREEN, this session): this
## fixture's own P1(-1.5)/P2(0) placement is asymmetric enough that the
## raw child-centered midpoint (0.5, Track 6 sec2.4) falls OUTSIDE
## [-1.5, 0] -- Track 3 clamps it to P2's own x (0, the nearer boundary),
## +1e-3 (now tied with P2 at gen 0, broken by the existing final
## de-collision pass). Found live this session -- not one of the plan's
## own named S583 examples, but the same clamp mechanism applies to
## every union, confirming the fix is general, not case-specific.
test_that(".positionMatingUnitForest positions a simple 2-parent/3-child
           trio with the union's x clamped to its nearer parent's own x
           (Track 3) -- the children's own midpoint (Track 6 sec2.4)
           would otherwise fall outside P1/P2's own span -- and 3
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
  expect_equal(unionX, 0.001, tolerance = 1e-6)

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
## Track 6 update (docs/planning/pedigree-diagram-track6-child-centered-
## union-position-plan.md, this session): a mating unit's final x is now
## the midpoint of its OWN CHILDREN's final x (§2.1), not its 2 parents'
## midpoint -- all 4 union values (unit1-4) and the duplicate (dupAt4)
## change; unit1/unit4 additionally absorb the existing final de-collision
## pass's 1e-3 epsilon nudge (§2.3), since each exactly ties its single
## child's x at the same gen -- see the docstring immediately above the
## expectPos() calls below for why unit1/unit4 (not 8DKELJ/FJIB3R) are the
## ones nudged. dupX is now derived from the new finalUnitX (§2.2). 1 REAL
## individual value also changes -- NOT "union/duplicate values only",
## confirmed by empirical Pre-RED validation before writing this test:
## 9VGCCV shifts by a real 0.5 units, because §2.2 removes duplicates from
## Track 3's sweepIds/sweepGen input set, which changes the gen-2 sweep's
## own competition (previously 3 entries:
## FJIB3R/9VGCCV/dupAt4; now 2: FJIB3R/9VGCCV) -- a real, non-epsilon
## consequence of §2.2 the design doc's own §5 Impact Analysis table did
## not state (it claimed real-individual sweeping is "otherwise
## unchanged"). Every value below re-verified live against a from-scratch
## reimplementation of Extended Candidate A (§2.1-2.3) run against
## UNMODIFIED .buildMatingUnitForest() output, not hand-derived --
## matching this project's own established Track 3/4 practice.

test_that(".positionMatingUnitForest's exact x/gen values for the real
           GA204Z/8LKBV9 loop fixture reflect Track 4's gen-first D2
           anchor selection -- 8LKBV9 now anchors his 2 founder mates
           (gen alone beats founder-preference's old outcome for the same
           winner) but loses the anchor role for 8P17E3's unit to 8LKBV9
           himself (gen 1 beats her gen 0), and issue #143's non-anchor
           override still renders her at her unit's gen. 5A6DFT/8DKELJ's
           own x values reflect issue #145 (male-left/female-right
           default, D2/D3), unaffected by Track 4. Every value below
           additionally reflects Track 3's minSep guarantee, AND Track 6's
           child-centered union/duplicate x formula (sec2.1/sec2.2).", {
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

  expectPos("5A6DFT", -0.50, 0L)  # issue #145: male left; unaffected by Track 4
  expectPos("8DKELJ", 0.50, 0L)  # unaffected by Track 4 (the de-collision
                                  # epsilon lands on unit1 instead -- see
                                  # below; locale-independent, method="radix")
  expectPos("G8EBU9", -0.75, 1L)  # issue #143; x CHANGED (8LKBV9 now
                                    # anchors this unit's OWN subtree merge
                                    # differently, since he also anchors
                                    # unit3 now)
  expectPos("8P17E3", 1.50, 1L)  # gen: issue #143's non-anchor override
                                  # (she no longer anchors unit3, 8LKBV9
                                  # does -- Track 4); x CHANGED
  expectPos("8LKBV9", 0.50, 1L)  # x CHANGED: his own gen (1), unrelocated
                                  # -- he now anchors BOTH founder units
  expectPos("FJIB3R", 0.25, 2L)  # still anchors unit4 (gen 2 beats
                                  # 8LKBV9's gen 1), unaffected (the
                                  # de-collision epsilon lands on unit4
                                  # instead -- see below)
  expectPos("9VGCCV", 1.75, 2L)  # Track 6: CHANGED, a REAL (non-epsilon)
                                  # shift -- §2.2 drops duplicates from
                                  # Track 3's gen-2 sweep competition (was
                                  # 3 entries, now 2), see docstring above
  expectPos("GA204Z", 0.25, 3L)  # x CHANGED

  unit1 <- forest$matingUnits$id[forest$matingUnits$sire == "5A6DFT"]
  unit2 <- forest$matingUnits$id[forest$matingUnits$dam == "G8EBU9"]
  unit3 <- forest$matingUnits$id[forest$matingUnits$dam == "8P17E3"]
  unit4 <- forest$matingUnits$id[forest$matingUnits$dam == "FJIB3R"]
  ## Track 6: every mating-unit dot's x is now the midpoint of its OWN
  ## CHILDREN's final x (§2.1), not its 2 parents' midpoint. unit1 and
  ## unit4 each land in an exact-coincidence tie with a real individual at
  ## the same gen (0 and 2 respectively) that the broadened de-collision
  ## pass (§2.3) breaks with a 1e-3 epsilon nudge -- WHICH of the 2 tied
  ## nodes gets nudged is decided by the de-collision loop's own
  ## (gen, id)-order iteration (`order(..., method = "radix")`, a
  ## deliberately locale-INDEPENDENT byte-order tie-break -- found live
  ## this session that the default (locale-dependent) `order()` gave a
  ## DIFFERENT answer under `LC_ALL=C` than under `en_US.UTF-8`, silently
  ## flipping which node absorbs the nudge and failing `R CMD check`'s own
  ## test run without ever touching a source file). Under byte order, a
  ## digit-leading real id ("8LKBV9") sorts before an underscore-leading
  ## union id ("__union_1") -- unit1/unit4 are visited LATER in the pass
  ## and so are the ones nudged, not 8DKELJ/FJIB3R.
  expectPos(unit1, 0.501, 0L)  # CHANGED: unit1's only child is 8LKBV9
                                 # (x=0.50) -- midpoint of a single child is
                                 # that child's own x, then +1e-3 (tied
                                 # with 8DKELJ at gen 0, radix-order nudges
                                 # unit1)
  expectPos(unit2, 0.25, 1L)  # CHANGED: unit2's only child is FJIB3R
                                # (x=0.25)
  expectPos(unit3, 1.501, 1L)   # Track 3 (this session): unit3's only
                                 # child is 9VGCCV (x=1.75), but that
                                 # exceeds sire 8LKBV9(0.5)/dam
                                 # 8P17E3(1.5)'s own span -- clamped to
                                 # 8P17E3's own x (1.5), then +1e-3 (now
                                 # tied with 8P17E3 at gen 1)
  expectPos(unit4, 0.251, 2L)  # CHANGED: unit4's only child is GA204Z
                                 # (x=0.25), then +1e-3 (tied with FJIB3R
                                 # at gen 2, radix-order nudges unit4)

  dupAt4 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit4]
  ## unit3 no longer has a duplicate (8LKBV9 anchors it directly now,
  ## §7 step 4's "duplicate-node count re-measurement" -- this fixture's
  ## own contribution to that drop).
  expect_equal(forest$duplicates$matingUnitId[
    forest$duplicates$realId == "8LKBV9"], unit4)
  expectPos(dupAt4, 0.65, 2L)  # Track 6: CHANGED (§2.2, dupX = new
                                # finalUnitX[unit4] + minSep*0.4 =
                                # 0.25 + 0.4); gen unaffected (unit4's own
                                # gen)
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

test_that(".positionMatingUnitForest guarantees at least minSep (1 unit)
           between every pair of same-generation REAL individual nodes --
           not just non-collision -- for the real GA204Z/8LKBV9 loop
           fixture", {
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

  ## REAL individual nodes only (Track 6 sec2.2) -- mating-unit "__union_*"
  ## dot nodes are derived midpoints of their own children, and duplicate
  ## "__dup_*" nodes are derived offsets of their own mating unit, neither
  ## independently laid-out leaves, so both are out of scope for the full
  ## minSep guarantee (union: this session's original PRE-RED
  ## AskUserQuestion decision; duplicate: Track 6 sec2.2, this session).
  indiv <- pos[.nodeKind(pos$id) == "individual", ]
  gens <- sort(unique(indiv$gen))
  minGaps <- vapply(gens, function(g) {
    xs <- sort(indiv$x[indiv$gen == g])
    if (length(xs) < 2L) return(Inf)
    min(diff(xs))
  }, numeric(1L))
  expect_true(all(minGaps >= 1L - 1e-6),
              info = paste("min gap per gen (", paste(gens, collapse = ","),
                            "):", paste(round(minGaps, 3), collapse = ", ")))
})

## ---- issue #145 Slice 1: male-left/female-right default (D1-D4) -------
## docs/planning/issue145-sire-dam-left-right-placement-plan.md. The new
## 'orderBySex' parameter (default TRUE) is additive: orderBySex = FALSE
## must reproduce today's pre-#145 (sex-agnostic) output byte-for-byte, so
## every test below asserts against that baseline directly rather than
## hard-coding a second set of magic numbers -- the baseline call IS the
## regression guard for "nothing outside the swap changed."

test_that(".positionMatingUnitForest (orderBySex = TRUE, the default) swaps
           a D1-qualifying pair whose male parent would otherwise anchor
           (and so land right of the female parent); orderBySex = FALSE
           reproduces today's pre-#145 order unchanged", {
  ## AM (sire, 'M') < ZF (dam, 'F') lexically -> AM wins .buildMatingUnitForest()'s
  ## preferAnchor() id tie-break -> AM anchors, ZF is the free-pass parent
  ## (always leftmost, R/makePedigreeDiagramData.R:730) -> pre-#145, AM
  ## (male) ends up RIGHT of ZF (female) -- the case D2's swap exists for.
  ped <- data.frame(
    id = c("AM", "ZF", "K"),
    sire = c(NA, NA, "AM"), dam = c(NA, NA, "ZF"),
    sex = c("M", "F", "F"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  legacy <- .positionMatingUnitForest(ped, forest, orderBySex = FALSE)
  ordered <- .positionMatingUnitForest(ped, forest, orderBySex = TRUE)

  amLegacy <- legacy$x[legacy$id == "AM"]
  zfLegacy <- legacy$x[legacy$id == "ZF"]
  expect_true(amLegacy > zfLegacy)  # confirms this fixture DOES need a swap

  amOrdered <- ordered$x[ordered$id == "AM"]
  zfOrdered <- ordered$x[ordered$id == "ZF"]
  expect_true(amOrdered < zfOrdered)  # male now left, per D3
  expect_equal(amOrdered, zfLegacy, tolerance = 1e-6)  # D2: pure value swap
  expect_equal(zfOrdered, amLegacy, tolerance = 1e-6)

  ## Nothing else moves (D2's own safety argument): every id besides the
  ## swapped pair, plus the mating unit's own x (mean is swap-invariant).
  otherIds <- setdiff(ordered$id, c("AM", "ZF"))
  expect_equal(ordered$x[ordered$id %in% otherIds],
               legacy$x[legacy$id %in% otherIds], tolerance = 1e-6)
  .expectNoOverlap(ordered)
})

test_that(".positionMatingUnitForest (orderBySex = TRUE) leaves a
           D1-qualifying pair unchanged when the male parent already ends
           up left under today's default (a true no-op, not just 'no
           assertion failure')", {
  ## ZM (sire, 'M') > AF (dam, 'F') lexically -> AF wins the anchor
  ## tie-break -> ZM (male) is the free-pass parent -> already leftmost,
  ## pre-#145 -- D3's direction already holds by coincidence of id order,
  ## so orderBySex = TRUE must produce byte-identical output to FALSE.
  ped <- data.frame(
    id = c("ZM", "AF", "K"),
    sire = c(NA, NA, "ZM"), dam = c(NA, NA, "AF"),
    sex = c("M", "F", "F"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  legacy <- .positionMatingUnitForest(ped, forest, orderBySex = FALSE)
  ordered <- .positionMatingUnitForest(ped, forest, orderBySex = TRUE)

  expect_true(legacy$x[legacy$id == "ZM"] < legacy$x[legacy$id == "AF"])
  expect_equal(ordered$x, legacy$x, tolerance = 1e-6)  # true no-op
  .expectNoOverlap(ordered)
})

test_that(".positionMatingUnitForest (orderBySex = TRUE) never swaps a
           D1-excluded pair with an 'H'/'U'/NA sex code on either parent
           (D4) -- even when the id tie-break would otherwise force the
           male parent into the anchor role that needs a swap", {
  ambiguousCodes <- c("H", "U", NA_character_)
  for (code in ambiguousCodes) {
    ped <- data.frame(
      id = c("AM", "ZF", "K"),
      sire = c(NA, NA, "AM"), dam = c(NA, NA, "ZF"),
      sex = c(code, "F", "F"), gen = c(0L, 0L, 1L),
      stringsAsFactors = FALSE
    )
    forest <- .buildMatingUnitForest(ped)
    legacy <- .positionMatingUnitForest(ped, forest, orderBySex = FALSE)
    ordered <- .positionMatingUnitForest(ped, forest, orderBySex = TRUE)
    expect_equal(ordered$x, legacy$x, tolerance = 1e-6,
                 info = paste("sex code:", code))
  }
})

test_that(".positionMatingUnitForest (orderBySex = TRUE) swaps only the 2
           real parents' own x on a D1-qualifying pair with a wide,
           asymmetric multi-child fanout -- the exact shape issue #145's
           own adversarial review used to break the FIRST-draft 'reflect
           the subtree' mechanism (refuted, see the design doc's §3 D2/§7);
           re-verified live this session (Pre-RED) that the ratified
           value-swap mechanism does not reproduce that collision: every
           child, grandchild, and unrelated sibling is untouched", {
  ## AM/ZF as above (AM forced into anchor by the id tie-break, so a swap
  ## fires); 3 children C1/C2/C3 off the AM x ZF union, C2 (a middle
  ## child) carries 5 of her own children (GC1-5) with GCMate -- an
  ## asymmetric, wide fanout. S1 is an unrelated founder elsewhere in the
  ## tree (the reflection mechanism's own collision target).
  ped <- data.frame(
    id = c("AM", "ZF", "S1", "C1", "C2", "C3",
           "GCMate", "GC1", "GC2", "GC3", "GC4", "GC5"),
    sire = c(NA, NA, NA, "AM", "AM", "AM",
             NA, "C2", "C2", "C2", "C2", "C2"),
    dam = c(NA, NA, NA, "ZF", "ZF", "ZF",
            NA, "GCMate", "GCMate", "GCMate", "GCMate", "GCMate"),
    sex = c("M", "F", "F", "F", "M", "F",
            "F", "M", "F", "M", "F", "M"),
    gen = c(0L, 0L, 0L, 1L, 1L, 1L,
            1L, 2L, 2L, 2L, 2L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  legacy <- .positionMatingUnitForest(ped, forest, orderBySex = FALSE)
  ordered <- .positionMatingUnitForest(ped, forest, orderBySex = TRUE)

  expect_true(legacy$x[legacy$id == "AM"] > legacy$x[legacy$id == "ZF"])
  expect_true(ordered$x[ordered$id == "AM"] <
                ordered$x[ordered$id == "ZF"])

  ## C2 x GCMate (the fanout's own mates) is ALSO, independently, a
  ## D1-qualifying pair (mate-count 1 each, no D5 child, unambiguous sex)
  ## -- found live running this test (GREEN): the implementation correctly
  ## swaps it too, not just the outer AM/ZF pair. This is the intended
  ## behavior (D1 scopes per-unit, not "outermost unit only"), so this
  ## test asserts BOTH swaps rather than narrowing the fixture to avoid
  ## the second one.
  expect_true(legacy$x[legacy$id == "C2"] > legacy$x[legacy$id == "GCMate"])
  expect_true(ordered$x[ordered$id == "C2"] <
                ordered$x[ordered$id == "GCMate"])

  ## Only S1 (unrelated), C1/C3 (siblings), and GC1-5 (grandchildren) are
  ## truly untouched -- neither swapped pair's own children/other-parent.
  otherIds <- setdiff(ordered$id, c("AM", "ZF", "C2", "GCMate"))
  expect_equal(ordered$x[ordered$id %in% otherIds],
               legacy$x[legacy$id %in% otherIds], tolerance = 1e-6)
  .expectNoOverlap(ordered)
  .expectNoOverlap(legacy)
})

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
           established by Slice 1, with no overlap among
           individual/union nodes and no NA x/gen", {
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
  .expectNoOverlap(pos)
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

test_that(".positionMatingUnitForest resolves every NON-ANCHOR and every
           ANCHOR row mismatch on the real 375-individual bundled fixture
           (issue #143/#144 -- RESOLVED) -- relies on this fixture having
           no dangling sire/dam references (confirmed by
           test_buildMatingUnitForest.R's own dangling-reference test)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  posGen <- stats::setNames(pos$gen, pos$id)
  unitGen <- stats::setNames(forest$matingUnits$gen, forest$matingUnits$id)

  ## For each mating unit's side (sire, dam), find the node id that
  ## actually renders for THIS unit (the person's own real node, or their
  ## duplicate node if this unit is where they occur as a duplicate), and
  ## whether that side is the unit's anchor.
  mismatchSide <- function(personId, unitId, isAnchor) {
    dupId <- forest$duplicates$id[forest$duplicates$realId == personId &
                                     forest$duplicates$matingUnitId == unitId]
    nodeId <- if (length(dupId) == 1L) dupId else personId
    mismatched <- !identical(unname(posGen[[nodeId]]), unname(unitGen[[unitId]]))
    data.frame(isAnchor = isAnchor, mismatched = mismatched)
  }

  mu <- forest$matingUnits
  sideRows <- do.call(rbind, lapply(seq_len(nrow(mu)), function(i) {
    rbind(
      mismatchSide(mu$sire[i], mu$id[i], identical(mu$anchor[i], mu$sire[i])),
      mismatchSide(mu$dam[i], mu$id[i], identical(mu$anchor[i], mu$dam[i]))
    )
  }))

  expect_equal(sum(sideRows$mismatched & !sideRows$isAnchor), 0L)
  ## CHANGED from 51L -- issue #144's effGenOf fix (Candidate B) resolves
  ## every anchor-side mismatch on this fixture (no anchor here anchors
  ## multiple units at differing unitGen -- the one residual shape #144
  ## does not close; see the 2 new regression tests below).
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

## ---- Track 6 (child-centered mating-unit position): docs/planning/
## pedigree-diagram-track6-child-centered-union-position-plan.md §2.4's
## own invariant, plus the §2.3 duplicate-vs-any-node de-collision
## broadening. Both confirmed empirically to fail against UNMODIFIED
## source (Pre-RED, this session) before being committed here -- the §2.4
## invariant fails because current code centers a union over its 2
## PARENTS, not its children (baseline: 100/251 child edges >200 scaled
## units on the real fixture, per the design doc's own §1.4 measurement,
## reproduced live this session); the de-collision test fails because the
## real fixture already has 1 PRE-EXISTING duplicate/union exact
## coincidence current code's own de-collision pass does not reach
## (duplicates are excluded from it today) -- a gap this decision's §2.3
## closes as a side effect, not something §2.1/§2.2 alone introduce. -----

test_that(".positionMatingUnitForest's every mating unit satisfies the
           Track 6 §2.4 invariant, LOOSENED by Track 3 (docs/planning/
           pedigree-diagram-same-row-collision-avoidance-plan.md §2.3/§6
           Session C, a disclosed reopening of §2.4's 'unconditionally'
           wording, owner-ratified S592 §9) and by the Track-3-Engagement-
           Gated post-hoc duplicate-occurrence nudge (investigation doc
           docs/planning/pedigree-diagram-duplicate-occurrence-centering-
           investigation.md §10-§11, PRE-RED->RED this session): finalUnitX
           equals ONE OF (a) the midpoint of its own children's final x (the
           original Track 6 formula, whenever that already falls inside the
           union's own 2 parents' x-range), (b) that midpoint clamped into
           the parents' [min, max] range (Track 3, whenever (a) doesn't
           hold), or (c) NEW: .computeDupNudge()'s own preReclampTarget for
           this union, reclamped into the same [min, max] range Track 3
           uses, whenever the union is Track-3-engaged AND has >=1
           qualifying child -- within the existing 1e-3 de-collision
           epsilon's own tolerance -- on the small GA204Z/8LKBV9 loop
           fixture, the real 375-individual bundled fixture, and (NEW)
           .commentOneFixture()'s own P1/P2/A/Y/X/W/C1/GC/C2 pedigree --
           investigation doc §10.6/§11.3(a) established this is the ONLY
           known fixture, among this project's own test corpora, where the
           qualification rule actually fires (0/4 small, 0/237 real), so
           branch (c) is DEAD CODE (vacuously true) without it -- widening
           the disjunct alone, without this fixture, would not actually
           test anything new (§10.4/§11.3(c)'s own 'must not forget for
           RED' finding). Confirmed FAILING pre-GREEN this session (RED):
           .computeDupNudge() does not exist yet, so checkInvariant() itself
           errors on every call.", {
  checkInvariant <- function(ped) {
    forest <- .buildMatingUnitForest(ped)
    pos <- .positionMatingUnitForest(ped, forest)
    matingUnits <- forest$matingUnits
    duplicates <- forest$duplicates
    childEdges <- forest$childEdges
    ## NEW (investigation doc §11.1): finalUnitX passed to .computeDupNudge()
    ## is the ALREADY-CLAMPED (Track-3-alone) union x -- exactly what
    ## .positionMatingUnitForest() already has synced into pos$x for every
    ## union id at this point in the real pipeline.
    finalUnitX <- stats::setNames(pos$x[match(matingUnits$id, pos$id)],
                                   matingUnits$id)
    nudge <- .computeDupNudge(matingUnits, duplicates, childEdges, pos,
                               finalUnitX, minSep = 1)
    for (i in seq_len(nrow(matingUnits))) {
      uid <- matingUnits$id[i]
      kids <- childEdges$to[childEdges$from == uid]
      kidX <- pos$x[match(kids, pos$id)]
      formulaX <- (min(kidX) + max(kidX)) / 2
      sireX <- pos$x[pos$id == matingUnits$sire[i]]
      damX <- pos$x[pos$id == matingUnits$dam[i]]
      lo <- min(sireX, damX); hi <- max(sireX, damX)
      clampedX <- min(max(formulaX, lo), hi)
      target <- nudge[[uid]]$preReclampTarget
      nudgedX <- if (isTRUE(nudge[[uid]]$engaged) && !is.na(target)) {
        min(max(target, lo), hi)
      } else {
        clampedX
      }
      actual <- pos$x[pos$id == uid]
      ## Absolute-difference comparison (+ a 1e-9 float-representation
      ## buffer), matching the ORIGINAL expect_equal(actual, expected,
      ## tolerance = 2e-3)'s own semantics -- all.equal()'s default
      ## tolerance is RELATIVE, which spuriously flagged the small
      ## fixture's own __union_4 (formula/clamped 0.25, actual 0.251, a
      ## pre-existing 0.001 de-collision-epsilon nudge unrelated to Track
      ## 3): a 0.001 absolute difference is comfortably inside 2e-3
      ## absolute tolerance but exceeds a 2e-3 RELATIVE tolerance at this
      ## scale. The 1e-9 buffer absorbs a second, unrelated finding: the
      ## real 375-fixture's __union_5 lands EXACTLY 0.002000000 (two
      ## stacked 1e-3 de-collision nudges) from its own formula value --
      ## a real boundary case, not a rounding artifact, that a bare `<=`
      ## comparison can fail on float-representation noise alone (both
      ## found live this session, Pre-RED).
      expect_true(
        abs(actual - formulaX) <= 2e-3 + 1e-9 ||
          abs(actual - clampedX) <= 2e-3 + 1e-9 ||
          abs(actual - nudgedX) <= 2e-3 + 1e-9,
        info = paste("unit", uid, "formula", formulaX, "clamped",
                      clampedX, "nudged", nudgedX, "actual", actual))
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

test_that(".positionMatingUnitForest has zero exact x/gen coincidence
           among real, duplicate, AND mating-unit nodes together (Track 6
           §2.3's broadened de-collision pass) -- confirmed empirically
           this session (Pre-RED) that the real 375-individual bundled
           fixture already has 1 duplicate/union coincidence under
           UNMODIFIED source (a pre-existing gap this decision's own §2.3
           closes as a side effect, not a new regression §2.1/§2.2
           introduce)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  key <- paste(round(pos$x, 6), pos$gen)
  expect_false(any(duplicated(key)),
               info = paste("colliding ids:",
                             paste(pos$id[key %in% key[duplicated(key)]],
                                   collapse = ", ")))
})

## ---- Track 3 (parent-span clamp on finalUnitX): docs/planning/
## pedigree-diagram-same-row-collision-avoidance-plan.md §2.3/§6 Session
## C. Closes the BACKLOG.md S583 item. A disclosed, owner-ratified (S592
## §9, re-confirmed this session's own PRE-RED AskUserQuestion per the
## plan's own additional gate) reopening of Track 6 §2.4's
## "unconditionally" wording: a union's finalUnitX must be clamped into
## its own 2 parents' [min, max] x-range whenever the child-centered
## formula alone would place it outside that span. Both fixtures below
## confirmed empirically (Pre-RED, this session, via direct
## .positionMatingUnitForest()/makePedigreeMatingLayout() calls against
## UNMODIFIED source) to violate simple parent-span containment before
## being committed here. --------------------------------------------------

test_that(".positionMatingUnitForest clamps finalUnitX into its own 2
           parents' [min, max] x-range -- BACKLOG.md's own S583 concrete
           example, reproduced via trimPedigree() against the real
           375-individual bundled fixture (not a hand-built
           approximation)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  trimmed <- trimPedigree(c("8LKBV9", "FJIB3R", "GA204Z"), ped)
  forest <- .buildMatingUnitForest(trimmed)
  pos <- .positionMatingUnitForest(trimmed, forest)
  matingUnits <- forest$matingUnits

  for (i in seq_len(nrow(matingUnits))) {
    uid <- matingUnits$id[i]
    sireX <- pos$x[pos$id == matingUnits$sire[i]]
    damX <- pos$x[pos$id == matingUnits$dam[i]]
    lo <- min(sireX, damX); hi <- max(sireX, damX)
    ux <- pos$x[pos$id == uid]
    expect_true(ux >= lo - 2e-3 - 1e-9 && ux <= hi + 2e-3 + 1e-9,
                info = paste("unit", uid, "x", ux, "parent range",
                              lo, hi))
  }

  ## The headline S583 case, pinned to its own exact reported numbers
  ## (BACKLOG.md, scaled coordinates: 5A6DFT x=-60, 8DKELJ x=60,
  ## UNCLAMPED __union_1 x=120 -- entirely outside [-60,60], past the
  ## dam). Post-clamp, __union_1 must land AT the dam's own x (60), the
  ## nearer boundary of [-60,60] to the raw formula value of 120 --
  ## verified live this session via makePedigreeMatingLayout() against
  ## UNMODIFIED source (currently 120, confirmed failing), not estimated.
  ## expect_true()/abs(), NOT expect_equal(..., tolerance=1): waldo's
  ## `tolerance` is a RELATIVE-scale comparison, not an absolute-unit
  ## one -- expect_equal(120, 60, tolerance = 1) PASSES (found live this
  ## session), which would make this assertion pass both before AND
  ## after the clamp ships, silently proving nothing.
  scaled <- makePedigreeMatingLayout(trimmed)$nodes
  expect_equal(scaled$x[scaled$id == "5A6DFT"], -60)
  expect_equal(scaled$x[scaled$id == "8DKELJ"], 60)
  expect_true(abs(scaled$x[scaled$id == "__union_1"] - 60) < 1,
              info = paste("__union_1 x =",
                            scaled$x[scaled$id == "__union_1"]))
})

test_that(".positionMatingUnitForest clamps finalUnitX for every mating
           unit on the 9-subject P1/P2/A/Y/X/W/C1/C2/GC consanguineous
           fixture (test_makePedigreeMatingLayout.R's own Track C dogleg
           fixture, S563) -- BACKLOG.md's 'reproduced 3 more times'
           finding for the X×A, A×Y, and W×Y single-child
           unions, plus the P1×P2 founder union (a 2-child union
           also found, live this session, to violate containment)", {
  ped <- data.frame(
    id   = c("P1", "P2", "A", "Y", "X", "W", "C1", "C2", "GC"),
    sire = c(NA, NA, "P1", "P1", NA, NA, "A", "Y", "A"),
    dam  = c(NA, NA, "P2", "P2", NA, NA, "X", "W", "Y"),
    sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M"),
    gen  = c(0L, 0L, 1L, 1L, 3L, 1L, 4L, 2L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  matingUnits <- forest$matingUnits
  expect_equal(nrow(matingUnits), 4L)

  for (i in seq_len(nrow(matingUnits))) {
    uid <- matingUnits$id[i]
    sireX <- pos$x[pos$id == matingUnits$sire[i]]
    damX <- pos$x[pos$id == matingUnits$dam[i]]
    lo <- min(sireX, damX); hi <- max(sireX, damX)
    ux <- pos$x[pos$id == uid]
    expect_true(ux >= lo - 2e-3 - 1e-9 && ux <= hi + 2e-3 + 1e-9,
                info = paste("unit", uid, "(sire", matingUnits$sire[i],
                              "dam", matingUnits$dam[i], ") x", ux,
                              "parent range", lo, hi))
  }
})

## ---- Track-3-Engagement Gate (post-hoc duplicate-occurrence-selection
## centering nudge): docs/planning/pedigree-diagram-duplicate-occurrence-
## centering-investigation.md §10-§11. Closes the BACKLOG.md "Track 3's 2
## disclosed trade-offs" item's child-centering half (the D1 bar-vs-bar
## overlap half is untouched, tracked separately). A new internal helper,
## .computeDupNudge(matingUnits, duplicates, childEdges, nodes, finalUnitX,
## minSep), returns a list keyed by mating-unit id, each element
## list(qualifyingKids = character(), preReclampTarget = NA_real_,
## engaged = logical(1)) -- .positionMatingUnitForest() calls it strictly
## between Track 3's clamp loop and the nodes$x sync/dupX computation, and
## for every union where engaged is TRUE, reclamps preReclampTarget into
## the SAME [lo, hi] parent span Track 3 already computes, exactly as
## Track 3's own clamp does. All 6 fixtures below confirmed empirically
## (Pre-RED, this session, via direct .buildMatingUnitForest()/
## .positionMatingUnitForest()/makePedigreeMatingLayout() calls against
## UNMODIFIED source, plus an independent scratch reimplementation of the
## full gated design) -- not estimated or copied from the investigation
## doc's own worked examples, which use different fixture constructions
## with different (but qualitatively identical) numbers. -------------------

test_that(".computeDupNudge() qualifies exactly the documented children and
           computes the documented pre-reclamp target -- investigation doc
           §10-§11's qualification rule: child C of union U (K = U's own
           real children, |K|>=2) qualifies iff (a) C has EXACTLY ONE row
           in 'duplicates' with realId==C, whose matingUnitId V has an
           'other parent' also in K, AND (b) NONE of C's OTHER mating-unit
           memberships (excluding V) has an other-parent also in K. Target
           = midpoint of {non-qualifying kids' own real x} union
           {qualifying kids' own duplicate-anchored x, clipped into
           [min(realKidX), max(realKidX)]}. Confirmed FAILING pre-GREEN
           (RED): .computeDupNudge() does not exist yet.", {
  ## F1 (investigation doc's own target case, .commentOneFixture()'s
  ## pedigree): P1,P2 -> A,Y; A x Y consanguineous (A anchors); Y also
  ## mates outside founder W (duplicated at A x Y). __union_1's own child Y
  ## qualifies (her one duplicate row's other-parent A is a __union_1
  ## child too); A does not (0 duplicate rows -- she anchors everywhere).
  f1 <- data.frame(
    id   = c("P1", "P2", "X", "A", "Y", "W", "C1", "GC", "C2"),
    sire = c(NA, NA, NA, "P1", "P1", NA, "A", "A", "W"),
    dam  = c(NA, NA, NA, "P2", "P2", NA, "X", "Y", "Y"),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  f1$gen <- findGeneration(f1$id, f1$sire, f1$dam)
  forest1 <- .buildMatingUnitForest(f1)
  pos1 <- .positionMatingUnitForest(f1, forest1)
  finalUnitX1 <- stats::setNames(pos1$x[match(forest1$matingUnits$id, pos1$id)],
                                  forest1$matingUnits$id)
  nudge1 <- .computeDupNudge(forest1$matingUnits, forest1$duplicates,
                              forest1$childEdges, pos1, finalUnitX1, minSep = 1)
  expect_identical(nudge1[["__union_1"]]$qualifyingKids, "Y")
  expect_equal(nudge1[["__union_1"]]$preReclampTarget, -0.05)
  expect_true(nudge1[["__union_1"]]$engaged)

  ## F2 (wrong-direction, investigation doc §5.2's shape): P1,P2 -> A,B,C;
  ## A x B anchored by A, B x C anchored by C -- B is free-pass at A x B
  ## (fails clause (b): that free membership's other-parent A is also a
  ## __union_1 child) and duplicated only at B x C. 0 qualifying children.
  f2 <- data.frame(
    id   = c("P1", "P2", "A", "B", "C", "AB1", "BC1"),
    sire = c(NA, NA, "P1", "P1", "P1", "A", "B"),
    dam  = c(NA, NA, "P2", "P2", "P2", "B", "C"),
    sex  = c("M", "F", "M", "F", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
  f2$gen <- findGeneration(f2$id, f2$sire, f2$dam)
  forest2 <- .buildMatingUnitForest(f2)
  pos2 <- .positionMatingUnitForest(f2, forest2)
  finalUnitX2 <- stats::setNames(pos2$x[match(forest2$matingUnits$id, pos2$id)],
                                  forest2$matingUnits$id)
  nudge2 <- .computeDupNudge(forest2$matingUnits, forest2$duplicates,
                              forest2$childEdges, pos2, finalUnitX2, minSep = 1)
  expect_identical(nudge2[["__union_1"]]$qualifyingKids, character(0))
  expect_true(is.na(nudge2[["__union_1"]]$preReclampTarget))

  ## F3 (compounding, investigation doc §8.3's shape): P1,P2 -> A,Y,Q; Q
  ## mates both A and Y (2 extra outside mates R1,R2 flip preferAnchor()'s
  ## mate-count tie-break so Q, not A/Y, is the duplicated side at BOTH
  ## A x Q and Y x Q) -- Q fails clause (a) outright (2 duplicate rows, not
  ## exactly 1). 0 qualifying children.
  f3 <- data.frame(
    id   = c("P1", "P2", "A", "Y", "Q", "R1", "R2", "AQ1", "YQ1", "QR1c", "QR2c"),
    sire = c(NA, NA, "P1", "P1", "P1", NA, NA, "A", "Y", "Q", "Q"),
    dam  = c(NA, NA, "P2", "P2", "P2", NA, NA, "Q", "Q", "R1", "R2"),
    sex  = c("M", "F", "M", "F", "F", "M", "M", "F", "F", "F", "F"),
    stringsAsFactors = FALSE
  )
  f3$gen <- findGeneration(f3$id, f3$sire, f3$dam)
  forest3 <- .buildMatingUnitForest(f3)
  pos3 <- .positionMatingUnitForest(f3, forest3)
  finalUnitX3 <- stats::setNames(pos3$x[match(forest3$matingUnits$id, pos3$id)],
                                  forest3$matingUnits$id)
  nudge3 <- .computeDupNudge(forest3$matingUnits, forest3$duplicates,
                              forest3$childEdges, pos3, finalUnitX3, minSep = 1)
  expect_identical(nudge3[["__union_1"]]$qualifyingKids, character(0))
  expect_true(is.na(nudge3[["__union_1"]]$preReclampTarget))
})

test_that(".computeDupNudge()'s target, once Stage 2's mandatory reclamp is
           applied, is bit-identical to Track-3-alone's own value when the
           reclamp fully erases it -- the already-accepted invariant-
           preservation erasure trade-off (investigation doc §10.4 point 1),
           explicitly NOT fixed by the Track-3-Engagement Gate (the gate's
           own precondition, engaged==TRUE, is what makes a union eligible
           for erasure in the first place, per §11.2's own
           'provably out of scope' finding). Confirmed FAILING pre-GREEN
           (RED): .computeDupNudge() does not exist yet.", {
  ## Minimal P,Q -> B,A ; W x B -> BWkid (processed first, consumes B's
  ## free-pass) ; A x B -> GC (B genuinely duplicated there). B qualifies
  ## (her one duplicate row's other-parent A is a __union_1 child; her free
  ## membership W x B's other-parent W is not). Stage 1's target lands
  ## outside __union_1's own parent span; Stage 2's mandatory reclamp
  ## forces it back to exactly Track-3-alone's own (engaged) clamped value.
  erasure <- data.frame(
    id   = c("P", "Q", "W", "B", "A", "BWkid", "GC"),
    sire = c(NA, NA, NA, "P", "P", "W", "A"),
    dam  = c(NA, NA, NA, "Q", "Q", "B", "B"),
    sex  = c("M", "F", "M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  erasure$gen <- findGeneration(erasure$id, erasure$sire, erasure$dam)
  forest <- .buildMatingUnitForest(erasure)
  pos <- .positionMatingUnitForest(erasure, forest)
  finalUnitX <- stats::setNames(pos$x[match(forest$matingUnits$id, pos$id)],
                                 forest$matingUnits$id)
  nudge <- .computeDupNudge(forest$matingUnits, forest$duplicates,
                             forest$childEdges, pos, finalUnitX, minSep = 1)
  expect_identical(nudge[["__union_1"]]$qualifyingKids, "B")
  expect_equal(nudge[["__union_1"]]$preReclampTarget, 1.25)
  expect_true(nudge[["__union_1"]]$engaged)

  ## Stage 2: reclamp preReclampTarget into __union_1's own [lo, hi] parent
  ## span -- must land bit-identical to Track-3-alone's own shipped
  ## (engaged) value, i.e. today's UNMODIFIED-source finalUnitX for
  ## __union_1, confirming the reclamp neither improves nor worsens this
  ## already-disclosed trade-off.
  sireX <- pos$x[pos$id == forest$matingUnits$sire[1]]
  damX <- pos$x[pos$id == forest$matingUnits$dam[1]]
  lo <- min(sireX, damX); hi <- max(sireX, damX)
  reclamped <- min(max(nudge[["__union_1"]]$preReclampTarget, lo), hi)
  trackThreeAlone <- min(max((min(pos$x[pos$id %in% c("B", "A")]) +
                                 max(pos$x[pos$id %in% c("B", "A")])) / 2,
                              lo), hi)
  expect_equal(reclamped, trackThreeAlone)
})

test_that("the Track-3-Engagement Gate suppresses a would-be-corrupting
           nudge on a union whose own Track 3 clamp never engaged (the
           worse-than-erasure nested/chained regression, investigation doc
           §10.4/§11.1/§11.2) -- black-box, on the outer
           makePedigreeMatingLayout() surface. P1,P2 -> A,Y; A x Y
           (__union_2) -> GC1,GC2; GC1 x GC2 (__union_3) -> GGC; GC2 also
           mates outside founder W2 -> GGC2 (duplicates GC2 at
           __union_3). __union_2's own raw Track-6 midpoint of {GC1,GC2}
           already equals its Track-3-clamped value (engaged==FALSE) --
           Track 3 alone already has nothing to fix there. GC2 nevertheless
           qualifies as __union_2's own child (her one duplicate row, at
           __union_3, has other-parent GC1 also in K={GC1,GC2}), so an
           UNGATED nudge would corrupt __union_2's already-correct output;
           the gate must suppress it. Confirmed empirically this session
           (Pre-RED, against UNMODIFIED source): __union_2 currently ships
           at x=90 (0.75 abstract * xScale 120) -- this is what the gated
           design must reproduce exactly. Confirmed FAILING pre-GREEN
           (RED): the nudge does not exist yet, so this union's own value
           is merely today's un-nudged Track-3-alone output, which happens
           to already equal 90 for an unrelated reason (no code exists yet
           to corrupt it) -- GREEN must prove this stays true once the
           qualifying-but-not-engaged nudge is wired in, not merely that it
           is untouched because nothing has been implemented -- a white-box
           .computeDupNudge() assertion below (qualifyingKids=='GC2',
           engaged==FALSE) makes this test FAIL pre-GREEN regardless (RED),
           since that function does not exist yet; the black-box outer
           assertion alone would otherwise pass vacuously today.", {
  nested <- data.frame(
    id   = c("P1", "P2", "A", "Y", "GC1", "GC2", "W2", "GGC", "GGC2"),
    sire = c(NA, NA, "P1", "P1", "A", "A", NA, "GC1", "W2"),
    dam  = c(NA, NA, "P2", "P2", "Y", "Y", NA, "GC2", "GC2"),
    sex  = c("M", "F", "M", "F", "M", "F", "M", "M", "F"),
    stringsAsFactors = FALSE
  )
  nested$gen <- findGeneration(nested$id, nested$sire, nested$dam)

  forest <- .buildMatingUnitForest(nested)
  pos <- .positionMatingUnitForest(nested, forest)
  finalUnitX <- stats::setNames(pos$x[match(forest$matingUnits$id, pos$id)],
                                 forest$matingUnits$id)
  nudge <- .computeDupNudge(forest$matingUnits, forest$duplicates,
                             forest$childEdges, pos, finalUnitX, minSep = 1)
  expect_identical(nudge[["__union_2"]]$qualifyingKids, "GC2")
  expect_false(nudge[["__union_2"]]$engaged)

  layout <- makePedigreeMatingLayout(nested, edgeStyle = "direct")
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_2"], 90)
})

test_that("the Track-3-Engagement Gate does not over-suppress a genuinely
           Track-3-engaged union's own legitimate correction (investigation
           doc §11.3 finding 3's 'inner-engaged' corner) -- black-box, on
           the outer makePedigreeMatingLayout() surface. Same base shape as
           the nested-regression fixture above, but A additionally mates
           outside founder X -> C1 (mirrors F1's own A x X shape), which
           flips preferAnchor()'s tie-break so Y (not A) anchors A x Y --
           A's own extra branch now makes __union_3 (A x Y) genuinely
           Track-3-engaged (raw=1.875 != clamped=1.626, a real 0.249
           clamp, confirmed via direct instrumentation this session, not
           the ~0.001 de-collision-epsilon noise floor). GC2 qualifies as
           __union_3's own child exactly as in the nested-regression
           fixture; her Stage-1 target (1.0755 abstract) SURVIVES Stage 2's
           reclamp (falls inside __union_3's own [-0.125, 1.625] parent
           span) -- a real, needed correction the gate must NOT suppress.
           Confirmed empirically this session (Pre-RED): __union_3 ships
           today (UNMODIFIED source, Track-3-alone) at x=195.12; once
           gated GREEN, it must move to 1.0755*120=129.06, confirming the
           gate permits engaged unions through unchanged. Confirmed FAILING
           pre-GREEN (RED): the nudge does not exist yet, so __union_3
           stays at today's un-nudged 195.12, not the corrected 129.06.", {
  notover <- data.frame(
    id   = c("P1", "P2", "A", "Y", "X", "C1", "GC1", "GC2", "W2", "GGC", "GGC2"),
    sire = c(NA, NA, "P1", "P1", NA, "A", "A", "A", NA, "GC1", "W2"),
    dam  = c(NA, NA, "P2", "P2", NA, "X", "Y", "Y", NA, "GC2", "GC2"),
    sex  = c("M", "F", "M", "F", "F", "F", "M", "F", "M", "M", "F"),
    stringsAsFactors = FALSE
  )
  notover$gen <- findGeneration(notover$id, notover$sire, notover$dam)
  layout <- makePedigreeMatingLayout(notover, edgeStyle = "direct")
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_3"], 129.06,
               tolerance = 0.01)
})

test_that("the Track-3-Engagement Gate is always suppressed for a
           dangling-parent mating unit (investigation doc §11.3 finding 2's
           previously-undisclosed corollary): Track 3's own clamp loop
           unconditionally skips a union whose sire or dam has no own row
           in 'ped' (its own 'if (!anyNA(parentX))' guard), so
           rawFinalUnitX and clampedFinalUnitX are always byte-identical
           for such a union -- engaged is therefore always FALSE,
           regardless of how many children would otherwise qualify. This
           fixture has no qualifying children (no 'duplicates' rows at
           all), so it exercises only the structural no-crash/no-change
           half of the corollary, not a simultaneously-qualifying corner
           (disclosed, not fixed, matching this investigation's own
           established practice of naming an unexercised corner rather
           than silently skipping it). Confirmed FAILING pre-GREEN (RED):
           .computeDupNudge() does not exist yet.", {
  dangling <- data.frame(
    id   = c("M1", "F1", "K1", "K2"),
    sire = c(NA, NA, "DANGLING_SIRE", "DANGLING_SIRE"),
    dam  = c(NA, NA, "F1", "F1"),
    sex  = c("M", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
  suppressWarnings(
    dangling$gen <- findGeneration(dangling$id, dangling$sire, dangling$dam)
  )
  forest <- .buildMatingUnitForest(dangling)
  pos <- .positionMatingUnitForest(dangling, forest)
  finalUnitX <- stats::setNames(pos$x[match(forest$matingUnits$id, pos$id)],
                                 forest$matingUnits$id)
  nudge <- .computeDupNudge(forest$matingUnits, forest$duplicates,
                             forest$childEdges, pos, finalUnitX, minSep = 1)
  expect_false(nudge[["__union_1"]]$engaged)
})

test_that(".positionMatingUnitForest's F1 target case (investigation doc's
           own .commentOneFixture() pedigree) produces the exact, single
           documented nudged value on the outer makePedigreeMatingLayout()
           surface -- a STRICT, single-value regression assertion
           independent of checkInvariant()'s own loose 3-way OR sweep
           above, which cannot by itself distinguish 'the nudge correctly
           fired' from 'the whole mechanism silently never fired at all'
           (investigation doc §11.3's own 'must-not-forget for RED'
           finding). Confirmed FAILING pre-GREEN (RED): __union_1 ships
           today (UNMODIFIED source) at x=0.12, not the documented
           -6.0 (-0.05 abstract * xScale 120).", {
  f1 <- data.frame(
    id   = c("P1", "P2", "X", "A", "Y", "W", "C1", "GC", "C2"),
    sire = c(NA, NA, NA, "P1", "P1", NA, "A", "A", "W"),
    dam  = c(NA, NA, NA, "P2", "P2", NA, "X", "Y", "Y"),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  f1$gen <- findGeneration(f1$id, f1$sire, f1$dam)
  layout <- makePedigreeMatingLayout(f1, edgeStyle = "direct")
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_1"], -6.0)
})
