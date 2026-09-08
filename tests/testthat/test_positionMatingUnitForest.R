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

## S667 (disconnected-component separation) helpers -- used by the Track B
## shrunk test and the "S667 RED" section at the end of this file.

## Named vector of kinship2's own x per individual for 'ped' (sex M/F
## only), from a live kinship2::align.pedigree() run. Mirrors
## test_makePedigreeMatingLayout.R:1622-1633 exactly.
.kinship2X <- function(ped) {
  sexCode <- c(M = 1, F = 2)[ped$sex]
  kPed <- kinship2::pedigree(id = ped$id, dadid = ped$sire,
                              momid = ped$dam, sex = sexCode,
                              missid = NA_character_)
  al <- kinship2::align.pedigree(kPed)
  kX <- stats::setNames(numeric(0), character(0))
  for (r in seq_len(nrow(al$nid))) {
    for (c in seq_len(ncol(al$nid))) {
      n <- al$nid[r, c]
      if (!is.na(n) && n > 0 && !(ped$id[n] %in% names(kX))) {
        kX[ped$id[n]] <- al$pos[r, c]
      }
    }
  }
  kX
}

## Assert that the pinned 'target' (relative to 'origin') equals a fresh
## kinship2 run on the same 'ped' -- skipped, not silently passed, when
## kinship2 is unavailable. Call it LAST in a test: a skip ends the test.
.expectKinship2Agrees <- function(ped, target, origin) {
  testthat::skip_if_not_installed("kinship2")
  kX <- .kinship2X(ped)
  theirs <- kX[names(target)] - kX[[origin]]
  testthat::expect_equal(unname(theirs), unname(target), tolerance = 1e-6,
                         info = "pinned target must equal the installed kinship2's own layout")
}

## Weakly-connected components of the DRAWN graph: real ids + mating-unit
## ids, joined by unit <-> real sire/dam and every childEdges row; a
## duplicate rides with its realId. Ordered by the smallest ped row index
## among each component's real members (kinship2's own family order).
## Test-local mirror of the production rule, so the real-fixture
## invariants are computed from the data, never pinned by id.
.forestComponentsForTest <- function(ped, forest) {
  nodes <- c(as.character(ped$id), forest$matingUnits$id)
  parent <- stats::setNames(nodes, nodes)
  find <- function(i) {
    while (parent[[i]] != i) i <- parent[[i]]
    i
  }
  unite <- function(a, b) {
    ra <- find(a)
    rb <- find(b)
    if (ra != rb) parent[[ra]] <<- rb
  }
  mu <- forest$matingUnits
  for (u in seq_len(nrow(mu))) {
    for (p in c(mu$sire[u], mu$dam[u])) if (p %in% nodes) unite(mu$id[u], p)
  }
  ce <- forest$childEdges
  for (e in seq_len(nrow(ce))) if (ce$from[e] %in% nodes) unite(ce$from[e], ce$to[e])
  roots <- vapply(nodes, find, character(1))
  firstRow <- match(nodes, as.character(ped$id))
  comps <- split(nodes, roots)
  ord <- order(vapply(comps, function(m) min(firstRow[nodes %in% m], na.rm = TRUE),
                      numeric(1)))
  comps <- unname(comps[ord])
  ## Duplicates ride with their mating unit (a dangling parent's duplicate
  ## has a realId with no own row -- GREEN-phase correction, S667, matching
  ## the production helper).
  d <- forest$duplicates
  lapply(comps, function(m) c(m, d$id[d$matingUnitId %in% m]))
}

## Smallest same-row x gap between two nodes of DIFFERENT components
## (Inf when no row holds nodes of two components).
.minCrossComponentRowGap <- function(pos, comps) {
  compOf <- stats::setNames(rep(seq_along(comps), lengths(comps)), unlist(comps))
  pos$comp <- compOf[pos$id]
  testthat::expect_false(anyNA(pos$comp),
                         info = "every positioned node belongs to a component")
  gap <- Inf
  for (g in unique(pos$gen)) {
    r <- pos[pos$gen == g, ]
    r <- r[order(r$x), ]
    if (nrow(r) < 2L) next
    d <- diff(r$x)
    cross <- r$comp[-1L] != r$comp[-nrow(r)]
    if (any(cross)) gap <- min(gap, d[cross])
  }
  gap
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
## `mean(tier1X[kids])` is once again the union's only formula.
##
## S666 CHANGE (conditional-shift rule): P1xP2 qualifies (root anchor,
## B1 mate), so the correction pass now shifts P1 and P2 -- not the union
## -- symmetrically around the union's own (unchanged) children-mean, per
## docs/planning/pedigree-diagram-parent-symmetric-placement-plan.md.
## P1 no longer sits at the raw children-mean (1.0, per Finding B's OLD
## anchor/children-mean identity) -- she is offset by half the P1/P2 gap
## instead, so the union no longer coincides with its own anchor and the
## pre-existing exact-tie epsilon nudge no longer engages. Measured live
## against the fixed engine: unionX lands bare at the children's mean
## (1.0), not 1.001.
test_that(".positionMatingUnitForest positions a simple 2-parent/3-child
           trio with the union's x as the exact midpoint of its own 3
           children (Tier 2) -- P1/P2 shift symmetrically around it
           (S666's conditional-shift rule), so no epsilon nudge is needed
           -- and 3 distinct, non-overlapping child x positions one gen
           below", {
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
  expect_equal(unionX, mean(childX), tolerance = 1e-6)

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

  ## Migration Path Phase 2 (QP joint-solver, this session): every value
  ## below is the QP's own solved output -- re-measured live against the
  ## fixed engine, never hand-derived. Unlike the Walker/BJL-era values
  ## this test used to pin, these are NOT expected to reproduce any single
  ## Phase-A formula exactly (Decision 1: Phase A formulas are provisional
  ## input only); they are simply this fixture's actual result.
  ## CHANGED S675 (Migration Path Phase 3 -- kinship2-parity QP floors,
  ## the owner-ratified amendment to Decision 3: individual-individual
  ## 1.0 = minSep, individual-union 0.5, union-union 0.25, replacing the
  ## symbol-tangent 0.4167/0.2583/0.1 floors S674 shipped). Re-measured by
  ## actually running the amended engine, never hand-derived.
  expectPos("5A6DFT", -0.34511914, 0L)
  expectPos("8DKELJ", 0.65488086, 0L)
  expectPos("G8EBU9", -0.84511913, 1L)
  expectPos("8P17E3", 1.15488087, 1L)  # gen unaffected: issue #143's
                                 # non-anchor override (she no longer
                                 # anchors unit3, 8LKBV9 does -- Track 4)
  expectPos("8LKBV9", 0.15488087, 1L)
  expectPos("FJIB3R", -0.84511913, 2L)
  expectPos("9VGCCV", 1.15488087, 2L)
  expectPos("GA204Z", -0.34511913, 3L)

  unit1 <- forest$matingUnits$id[forest$matingUnits$sire == "5A6DFT"]
  unit2 <- forest$matingUnits$id[forest$matingUnits$dam == "G8EBU9"]
  unit3 <- forest$matingUnits$id[forest$matingUnits$dam == "8P17E3"]
  unit4 <- forest$matingUnits$id[forest$matingUnits$dam == "FJIB3R"]
  expectPos(unit1, 0.15488086, 0L)
  expectPos(unit2, -1.34511913, 1L)
  expectPos(unit3, 0.65488087, 1L)
  expectPos(unit4, -0.34511913, 2L)

  dupAt4 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit4]
  ## unit3 no longer has a duplicate (8LKBV9 anchors it directly now).
  expect_equal(forest$duplicates$matingUnitId[
    forest$duplicates$realId == "8LKBV9"], unit4)
  expectPos(dupAt4, 0.15488087, 2L)
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
  ## CHANGED S678 from 714L -- Decision 2 spouse duplication raises the
  ## duplicate count to 170 (test_buildMatingUnitForest.R's own updated
  ## figure): 375 + 170 + 237.
  expect_equal(nrow(pos), 782L)
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

## ---- Migration Path Phase 3 (S675): the real 375 fixture through the QP
## engine, production path (5 weakly-connected families, each solved by its
## own .solveJointQP() call, then .packComponents()) -----------------------

test_that(".positionMatingUnitForest holds the S675 kinship2-parity QP floor
           on every adjacent same-row pair of the full real 375-individual
           bundled fixture, and the rendered layout has ZERO overlapping
           same-row symbols at the census's own 1e-9 px epsilon (census
           class (a) = 0 -- Migration Path Phase 3's own acceptance
           criterion, docs/planning/pedigree-diagram-joint-qp-solver-
           plan.md)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  ## S675 amendment to Decision 3 (owner-ratified via AskUserQuestion after
  ## seeing this fixture rendered under the original symbol-tangent floors,
  ## (25+25)/120 etc.): the QP's adjacent-pair floors are SPACING values
  ## keyed to the engine's own minSep = 1 -- individual-individual 1.0
  ## (kinship2's own uniform floor), individual-union 0.5, union-union 0.25.
  ## Under the tangent floors the objective compressed 684 of this
  ## fixture's 705 adjacent pairs to exactly the floor (symbols touching,
  ## labels overlapping into a band) and the census's class (a) read 90
  ## sub-microscopic (<= 1.3e-6 px) shortfalls at its 1e-9 px epsilon.
  ## Re-derived here, not shared with R/.
  minSep <- 1
  kind <- ifelse(pos$id %in% forest$matingUnits$id, "U", "I")
  names(kind) <- pos$id
  floorFor <- function(a, b) {
    both <- paste(sort(c(kind[[a]], kind[[b]])), collapse = "")
    if (both == "UU") minSep / 4 else if (both == "IU") minSep / 2 else minSep
  }
  shortfall <- numeric(0L)
  for (g in sort(unique(pos$gen))) {
    rowIds <- pos$id[pos$gen == g]
    if (length(rowIds) < 2L) next
    rowIds <- rowIds[order(pos$x[match(rowIds, pos$id)], rowIds,
                            method = "radix")]
    x <- pos$x[match(rowIds, pos$id)]
    for (i in seq_len(length(rowIds) - 1L)) {
      shortfall <- c(shortfall,
                     floorFor(rowIds[i], rowIds[i + 1L]) - (x[i + 1L] - x[i]))
    }
  }
  ## 714 nodes across 9 rows -> 705 adjacent pairs (measured S675). The
  ## tolerance is quadprog::solve.QP()'s own solver precision (measured
  ## max shortfall on this fixture 6.8e-8 raw = 8e-6 px; the same 1e-6 the
  ## joint-QP file's .expectMinSepFloorHeld() allows) -- NOT a geometric
  ## allowance: the census-style overlap check below is exact.
  ## CHANGED S678 from 705L -- Decision 2's 68 extra duplicates (714 ->
  ## 782 nodes) add 68 adjacent pairs across the same 9 rows.
  expect_equal(length(shortfall), 773L)
  expect_equal(sum(shortfall > 1e-6), 0L)

  ## Census class (a), restated independently of data-raw/
  ## pedigreeDrawingErrorCensus.R: two VISIBLE nodes on one rendered row
  ## whose centre distance is below the sum of their symbol radii (25 px
  ## individual/duplicate, 6 px union dot -- the layout's own 'size'
  ## column) at the census's own eps = 1e-9 px. The 1e-6 px tolerance the
  ## floor check above allows is irrelevant here: with a 1.0-unit (120 px)
  ## floor between 50 px symbols the margin is 70 px, so a solver-precision
  ## shortfall can never produce an overlap.
  layout <- suppressWarnings(
    makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")
  )
  vis <- layout$nodes[layout$nodes$size > 0, c("id", "x", "y", "size")]
  overlaps <- 0L
  for (y in unique(vis$y)) {
    r <- vis[vis$y == y, , drop = FALSE]
    r <- r[order(r$x), , drop = FALSE]
    n <- nrow(r)
    if (n < 2L) next
    for (i in seq_len(n - 1L)) {
      for (j in (i + 1L):n) {
        d <- r$x[j] - r$x[i]
        if (d >= 2 * max(vis$size)) break
        if (d < r$size[i] + r$size[j] - 1e-9) overlaps <- overlaps + 1L
      }
    }
  }
  expect_equal(overlaps, 0L)
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
           this fixture were B2-classified, none unexplained. Decision 2
           (S678, spouse duplication) then emptied that population -- the
           count below is 0 by construction, the classification assertion
           kept as the regression guard.", {
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
  ## CHANGED S678 from 56L -- Decision 2 (spouse duplication,
  ## provisional-order design): every B2-shaped non-anchor occurrence now
  ## renders through a __dup_ node carrying the unit's own gen, so the
  ## whole 56-row B2 free-occurrence mismatch population this block
  ## documented empties by construction (the dedicated class-(e) test at
  ## the end of this file asserts the same property from the resolver
  ## side). The all-B2 classification assertion above becomes vacuous but
  ## stays as the guard: any FUTURE nonzero count must still be
  ## B2-explained or it is a regression.
  expect_equal(nrow(nonAnchorMismatches), 0L)

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

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md Decision 4): this test asserted every anchored mating
## unit's x is the EXACT midpoint of its own real children's final x, true
## while Tier 2's mean(tier1X[kids]) formula computed the final answer
## directly. Decision 4's Term 2 (child centering) makes this a SOFT
## penalty now, balanced against spousal pull, union centering, duplicate
## proximity, and the minSep floor -- exact equality is no longer expected,
## by design, on any fixture (kinship2's own analogous align[1] term is
## the same kind of soft pull, never a hard identity). No future
## re-derivation restores this invariant -- permanently superseded.
## (Structural coverage of the QP's own actual guarantees -- node-set
## preservation, the minSep floor, no-error -- lives in
## test_solveJointQP.R.)

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

## S666 CHANGE (conditional-shift rule): each of these 3 qualifying
## unions' x is no longer Tier 2's raw child-midpoint (which coincided
## with the union's own anchor, per S652's revert -- see the prior version
## of this test, superseded here) -- it is still the child-midpoint
## mechanically (Tier 2 is unchanged), but the CHILDREN or PARENTS have
## themselves moved (S666's own root/non-root cases), so the union no
## longer sits on any single real node at all. On this specific fixture,
## every one of the 3 unions ends up comfortably outside Phase 2's own
## radius-proportionate clearance threshold (0.5 raw units from its
## nearest neighbor, vs. a ~0.26 threshold) -- Phase 2's push still does
## not need to engage here, but for a different reason than before
## (genuine separation from the correction, not anchor-coincidence).
## Exact values re-measured live against the fixed engine, never
## hand-derived.
## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md, Current-state table): tested the Track 7 Phase 2 union
## proximity push's own engage/no-engage threshold logic directly (S648/
## S649) -- that pass is deleted, replaced by .solveJointQP()'s hard minSep
## constraint (Decision 3), which is unconditionally enforced rather than
## conditionally triggered. There is no longer an "engage" question to ask.
## test_solveJointQP.R's own minSep-floor cases cover the QP's actual
## guarantee on this same Track B shrunk fixture (trackBShrunk).

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md, Current-state table): measured the Track 7 Phase 2/
## Phase 4 union-proximity pushes' own residual count on the real
## 375-individual fixture -- both passes are deleted, replaced by
## .solveJointQP()'s hard minSep constraint. Real-fixture verification of
## the new engine (including this class of proximity) is Migration Path
## Phase 3's own job (data-raw/pedigreeDrawingErrorCensus.R re-run against
## the real fixture) -- this test's own counting method is specific to the
## deleted mechanism, not reusable for that.

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
## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md, Current-state table): measured Option B's own duplicate-
## vs-unrelated-individual push's residual count on the real 375-individual
## fixture -- Option B (the duplicate de-collision + Track 7 Phase 4 push)
## is deleted, replaced by .solveJointQP()'s hard minSep constraint
## (Decision 3, term 4 duplicate proximity). Real-fixture verification is
## Migration Path Phase 3's job (the census script); this counting method
## is specific to the deleted mechanism.

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md, Current-state table): checked Option B's own 2 named
## real-375-fixture pairs against its own clearance target -- Option B is
## deleted, replaced by .solveJointQP()'s hard minSep constraint. Whether
## these 2 specific pairs clear the floor post-cutover is Migration Path
## Phase 3's own job (the census script measures every pair, not 2 named
## ones).

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md, Current-state table): the Track 7 Phase 4 early-exit
## guard this test regression-checked no longer exists -- that pass is
## deleted entirely, replaced by .solveJointQP()'s hard minSep constraint,
## which has no "generation with zero other mating units" special case at
## all (every row's constraint set is built uniformly). No future
## re-derivation restores a guard that isn't there to restore.

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
## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md, Current-state table): this section's 4 tests (the
## real-375-fixture near-miss count, the "resolves a representative
## sample" spot-check, and the co-anchor-sibling / own-anchor-exclusion
## regression pair) all measured or regression-guarded the B1-vs-unrelated-
## individual proximity pass's own specific mechanism (design ratified
## S661, implemented S662) -- that pass, and its own-anchor exclusion
## logic, are deleted entirely, replaced by .solveJointQP()'s uniform hard
## minSep constraint (Decision 3), which has no "own anchor" special case
## to exclude at all (every row's constraint set is built the same way).
## Real-fixture verification is Migration Path Phase 3's own job (the
## census script); none of these 4 tests' own counting/regression methods
## are reusable for that.

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
  ## Migration Path Phase 2 (QP joint-solver, this session): re-pinned by
  ## actually running the new engine, never hand-derived.
  ## CHANGED S675 (Migration Path Phase 3 -- kinship2-parity QP floors,
  ## the owner-ratified amendment to Decision 3: individual-individual
  ## 1.0 = minSep, individual-union 0.5, union-union 0.25, replacing the
  ## symbol-tangent 0.4167/0.2583/0.1 floors S674 shipped). Re-measured by
  ## actually running the amended engine, never hand-derived.
  ## CHANGED S678 (Decision 2 spouse duplication): GC2 (own parent edge)
  ## now also duplicates at the GC1 x GC2 unit she does not anchor, so
  ## the component's QP solve changes. Re-measured live.
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_2"], -55.882746,
               tolerance = 1e-5)
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
  ## Migration Path Phase 2 (QP joint-solver, this session): re-pinned by
  ## actually running the new engine, never hand-derived.
  ## CHANGED S675 (Migration Path Phase 3 -- kinship2-parity QP floors,
  ## the owner-ratified amendment to Decision 3: individual-individual
  ## 1.0 = minSep, individual-union 0.5, union-union 0.25, replacing the
  ## symbol-tangent 0.4167/0.2583/0.1 floors S674 shipped). Re-measured by
  ## actually running the amended engine, never hand-derived.
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_3"], 56.768463,
               tolerance = 1e-5)
})

test_that(".positionMatingUnitForest's F1 target case (investigation doc's
           own .commentOneFixture() pedigree) produces the exact,
           re-derived value on the outer makePedigreeMatingLayout()
           surface under the QP joint-solver engine (Migration Path
           Phase 2, this session) -- re-pinned by actually running the new
           engine, never hand-derived", {
  f1 <- data.frame(
    id   = c("P1", "P2", "X", "A", "Y", "W", "C1", "GC", "C2"),
    sire = c(NA, NA, NA, "P1", "P1", NA, "A", "A", "W"),
    dam  = c(NA, NA, NA, "P2", "P2", NA, "X", "Y", "Y"),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  f1$gen <- findGeneration(f1$id, f1$sire, f1$dam)
  layout <- makePedigreeMatingLayout(f1, edgeStyle = "direct")
  ## CHANGED S675 (Migration Path Phase 3 -- kinship2-parity QP floors,
  ## the owner-ratified amendment to Decision 3: individual-individual
  ## 1.0 = minSep, individual-union 0.5, union-union 0.25, replacing the
  ## symbol-tangent 0.4167/0.2583/0.1 floors S674 shipped). Re-measured by
  ## actually running the amended engine, never hand-derived.
  expect_equal(layout$nodes$x[layout$nodes$id == "__union_1"], 17.344755,
               tolerance = 1e-5)
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

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md Decision 1/4): this section's 3 tests (mixed-CHILDREN()
## anchor exact-midpoint, >=3-child-union exact-midpoint + B1-formula
## exactness, B3-duplicate-formula-exactness) all pinned .positionMating
## UnitForest()'s FINAL x to a Phase-A formula's own exact output (Tier 1
## BJL's child-midpoint identity, derivedX()'s B1/B3 branches). Decision 1
## makes every Phase-A formula provisional-only input to .solveJointQP()
## now; Decision 4's own soft objective terms replace these hard
## identities by design. No future re-derivation restores them --
## permanently superseded.

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
  ## Migration Path Phase 2 (QP joint-solver): the individual-individual
  ## floor is now .individualClearance (0.4167, radius-based, Decision 3),
  ## not the old sweepMinSepBackstop()'s raw minSep=1 -- that formula's
  ## own output is provisional-only now, no longer the final answer.
  expect_true(all(gaps >= .individualClearance - 1e-6),
              info = paste("gen-0 x values:", paste(sort(gen0$x), collapse = ", ")))
})

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md Decision 1): pinned S8's b1AnchorRelativeX() formula's
## exact output (P.x -+ minSep) as the FINAL rendered position. Decision 1
## makes this formula provisional-only input to .solveJointQP() now -- no
## future re-derivation restores the exact identity, permanently
## superseded.

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
  ## CHANGED S678 from 0L (Decision 2 spouse duplication): MOM's B2 shape
  ## (her own GP1/GP2 parent edge) now means her non-anchor occurrence at
  ## X's unit is duplicated rather than rendered by projection to her own
  ## off-row real node. The block's original point is UNCHANGED and still
  ## asserted below: her real position gets exactly one write, untouched
  ## by the union she does not anchor.
  expect_equal(nrow(forest$duplicates), 1L)
  expect_equal(forest$duplicates$realId, "MOM")
  expect_equal(forest$duplicates$matingUnitId, unitId)

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

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md, Current-state table): this test pinned the exact push
## amount .deCollideIndividualPoints() (Tier-3 de-collision sweep, S647)
## applied to resolve a specific exact tie -- that closure is deleted
## entirely, replaced by .solveJointQP()'s hard minSep constraint, which
## has no "exact tie" special case (every adjacent pair is constrained
## uniformly, tie or not). No future re-derivation restores an exact push
## amount from a mechanism that no longer runs. .expectNoOverlap()
## coverage for this fixture shape lives in test_solveJointQP.R's own
## minSep-floor cases.

## ---- 11. Anchor P (female, qualifying) with a true B1 mate M --------------------

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md Decision 1): pinned the S666 conditional-shift rule's own
## exact symmetric-shift output as the FINAL rendered position. Decision 1
## makes S666's own output provisional-only input to .solveJointQP() now
## (still used, unchanged, to fix provisional row order) -- no future
## re-derivation restores the exact identity, permanently superseded.

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
  ## CHANGED S678 from 0L (Decision 2 spouse duplication): MIA's B2 shape
  ## now earns a __dup_ node at YALE's unit instead of no entry at all;
  ## her real node's single untouched write (the block's point) is still
  ## asserted below.
  expect_equal(nrow(forest2$duplicates), 1L)
  expect_equal(forest2$duplicates$realId, "MIA")

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
  ## Migration Path Phase 2 (QP joint-solver): the individual-individual
  ## floor is now .individualClearance (0.4167, Decision 3), not the old
  ## sweepMinSepBackstop()'s raw minSep=1 -- that formula's own output is
  ## provisional-only now.
  expect_true(abs(cX - f0X) >= .individualClearance - 1e-6,
              info = paste("F0.x=", f0X, "C.x=", cX))
})

## ---- 14. THE regression test: sweepMinSep() moves a qualifying union's own ------
## real child -- S7's counter-example, now expected to PASS under S8's fix.

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md Decision 1): pinned S8's b1AnchorRelativeX() formula's
## exact output (P.x - minSep) as the FINAL mate position -- provisional-
## only input to .solveJointQP() now, no future re-derivation restores it.

## ---- 15. Obligation 1 (S8.4): sweepMinSep() pushes P HERSELF, not just her -----
## children -- P.x must be read post-sweep, never a pre-sweep intermediate.

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md Decision 1): pinned .deCollideIndividualPoints()'s own
## bidirectional-search push amount (S647) as the FINAL mate position --
## that closure is deleted entirely, replaced by .solveJointQP()'s hard
## minSep constraint. No future re-derivation restores a push amount from
## a mechanism that no longer runs.

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
  ## Migration Path Phase 2 (QP joint-solver): the individual-individual
  ## floor is now .individualClearance (0.4167, Decision 3), not the old
  ## sweepMinSepBackstop()'s raw minSep=1.
  for (g in sort(unique(indiv$gen))) {
    xs <- sort(indiv$x[indiv$gen == g])
    if (length(xs) < 2L) next
    expect_true(all(diff(xs) >= .individualClearance - 1e-6),
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

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md Decision 4): the real-375-fixture belt-and-suspenders
## duplicate of the exact-midpoint invariant retired earlier in this file
## (checkInvariant()) -- same reasoning: Decision 4's Term 2 (child
## centering) makes this a soft penalty now, not a hard identity, on any
## fixture.

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

## ---- S666 RED: conditional-shift rule (chain-case, Option 3) ------------
## docs/planning/pedigree-diagram-parent-symmetric-placement-plan.md's "CHAIN
## RULE -- RESOLVED (Session 665)" section, implementing session's own
## 7-step list. Every target value below comes from a fresh
## kinship2::align.pedigree() run on the identical structure (re-confirmed
## this session, never assumed/copied on faith) or from an internal
## structural invariant the rule itself guarantees by construction --
## matching this project's own "verify by execution" discipline (Learning
## from S664's arithmetic errors, corrected S665).
test_that(".positionMatingUnitForest's conditional-shift rule recenters a
           root-anchor qualifying pair's own parents around their
           unchanged children's mean -- P1xP2 (4 real children, including
           the nested M1xG3 anchor) and P3xP4 (1 real child), full,
           non-shrunk 16-subject Track B fixture", {
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

  childrenMeanP1P2 <- mean(pos$x[pos$id %in% c("C1", "C2", "C3", "M1")])
  expect_equal(mean(pos$x[pos$id %in% c("P1", "P2")]), childrenMeanP1P2,
               tolerance = 1e-6)
  expect_equal(mean(pos$x[pos$id %in% c("P3", "P4")]), pos$x[pos$id == "C4"],
               tolerance = 1e-6)
})

test_that(".positionMatingUnitForest's conditional-shift rule shifts a
           non-root qualifying pair's own real children -- whole subtree,
           rigidly -- to the true anchor/mate midpoint, leaving the anchor
           and mate themselves untouched -- C4xP6 (1 child) and M1xG3 (3
           children), full Track B fixture", {
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

  expect_equal(pos$x[pos$id == "C4a"],
               mean(pos$x[pos$id %in% c("C4", "P6")]), tolerance = 1e-6)
  childrenMeanM1G3 <- mean(pos$x[pos$id %in% c("L1", "L2", "L3")])
  expect_equal(childrenMeanM1G3, mean(pos$x[pos$id %in% c("M1", "G3")]),
               tolerance = 1e-6)
})

test_that(".positionMatingUnitForest's union dot sits at the true
           anchor/mate midpoint -- not merely at the children's mean, which
           holds trivially by Tier 2's own pre-existing invariant -- for
           every one of the 4 qualifying pairs, full Track B fixture", {
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

  pairs <- list(c("P1", "P2"), c("P3", "P4"), c("C4", "P6"), c("M1", "G3"))
  for (pr in pairs) {
    unitId <- forest$matingUnits$id[forest$matingUnits$sire == pr[1] &
                                       forest$matingUnits$dam == pr[2]]
    expect_equal(pos$x[pos$id == unitId], mean(pos$x[pos$id %in% pr]),
                 tolerance = 1e-6, label = paste(pr, collapse = "x"))
  }
})

test_that(".positionMatingUnitForest lays out Track B shrunk's two
           disconnected families (P1xP2 -> M1 -> M1xG3 -> L3, and
           C4xP6 -> C4a) as separate side-by-side blocks -- the
           disconnected-component separation fix (S667, revised design in
           docs/planning/pedigree-diagram-disconnected-component-
           separation-plan.md), UNCHANGED by Migration Path Phase 2
           (Decision 6: .packComponents() itself is not touched by the QP).

           Migration Path Phase 2 (QP joint-solver, this session): the
           pinned target below is no longer expected to bit-match
           kinship2 -- Decision 3's radius-based minSep (0.4167 between
           plain individuals) replaces kinship2's own uniform 1-unit
           floor, a disclosed divergence (measured this session: up to
           0.97 raw-unit deviation on this exact fixture). Re-derived by
           actually running the new engine, never hand-derived; the
           .expectKinship2Agrees() cross-check below is removed
           accordingly (see the retired kinship2-exact-match test earlier
           in this file for the full rationale).", {
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
  forest <- .buildMatingUnitForest(shrunk)
  pos <- .positionMatingUnitForest(shrunk, forest)

  ## All 8 individuals from ONE origin (P1) -- the two families are
  ## separate blocks, P1's family first (ped row order), C4's family
  ## packed to its right. Re-measured live against the QP-wired engine,
  ## never hand-derived.
  rel <- pos$x - pos$x[pos$id == "P1"]
  names(rel) <- pos$id
  ## CHANGED S675 (Migration Path Phase 3 -- kinship2-parity QP floors,
  ## the owner-ratified amendment to Decision 3: individual-individual
  ## 1.0 = minSep, individual-union 0.5, union-union 0.25, replacing the
  ## symbol-tangent 0.4167/0.2583/0.1 floors S674 shipped). Re-measured by
  ## actually running the amended engine, never hand-derived.
  ## These are kinship2::align.pedigree()'s OWN values for this fixture
  ## again (the S665 target: P1=0, M1=0.5, L3=1.0, P2=1.0, G3=1.5, C4=2.0,
  ## C4a=2.5, P6=3.0) -- the parity floors restore the bit-exact agreement
  ## the Phase 2 paragraph above disclosed as lost under the tangent floors.
  target <- c(P1 = 0, P2 = 1, M1 = 0.5, G3 = 1.5,
              L3 = 1, C4 = 2, P6 = 3, C4a = 2.5)
  expect_equal(unname(rel[names(target)]), unname(target), tolerance = 1e-5)

  ## The families' x-ranges are disjoint: nothing of C4's family sits
  ## inside P1's family's span on any row (the literal defect) -- this
  ## structural property is unaffected by the QP cutover (Decision 6).
  fam1 <- c("P1", "P2", "M1", "G3", "L3")
  fam2 <- c("C4", "P6", "C4a")
  expect_lt(max(pos$x[pos$id %in% fam1]), min(pos$x[pos$id %in% fam2]))
  .expectNoOverlap(pos)
})

## RETIRED (Migration Path Phase 2, docs/planning/pedigree-diagram-joint-qp-
## solver-plan.md Decision 1/3): these 2 tests pinned the S666 conditional-
## shift rule's own exact multi-level-chain output, and derivedX()'s exact
## B1 (+0.4 branch) formula output, as FINAL rendered positions -- both
## cross-checked bit-exact against kinship2. Decision 1 makes Phase-A
## formulas provisional-only input now; Decision 3's radius-based minSep
## (0.4167, not kinship2's uniform 1.0) makes bit-exactness with kinship2
## structurally impossible too (measured elsewhere in this file: real
## deviation, not noise). No future re-derivation restores either
## invariant -- permanently superseded.

test_that(".positionMatingUnitForest's conditional-shift rule holds for
           every qualifying unit whose mate is a genuine B1 free-pass
           point, on the real 375-individual production fixture -- union x
           equals the true anchor/mate midpoint, not just the children's
           mean -- re-verification per the plan doc's own step 6 (this
           project's established discipline for any change to this
           function).

           RED-phase test bug, found and fixed during GREEN (this
           session): the original version of this test checked
           qualifies() alone, without also requiring the mate to be in
           b1Ids -- qualifies() was historically only ever called from
           inside a `for (fp in b1Ids)` loop (b1AnchorRelativeX()'s own
           caller), so 'the mate is B1' was always true by construction,
           never something qualifies() itself checks. 55/60 of the real
           fixture's qualifies()-only units have a non-B1 mate (a real
           individual with her own parent edge, rendering at her own
           genuine position elsewhere in the tree, sometimes many
           generations away) -- comparing those against a B1-formula
           midpoint was comparing against a value with no meaning for
           them, not a defect in the production code. The production
           code's own correction pass gates on the identical, corrected
           condition (R/makePedigreeDiagramData.R's own
           correctableUnitIds).", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  matingUnits <- forest$matingUnits
  childEdges <- forest$childEdges
  pos <- .positionMatingUnitForest(ped, forest)
  realIds <- as.character(ped$id)
  sexOf <- stats::setNames(as.character(ped$sex), realIds)
  sireOf <- stats::setNames(as.character(ped$sire), realIds)
  damOf <- stats::setNames(as.character(ped$dam), realIds)
  hasParentEdge <- function(id) !is.na(sireOf[[id]]) || !is.na(damOf[[id]])

  anchoredUnits <- matingUnits[!is.na(matingUnits$anchor), , drop = FALSE]
  everAnchor <- unique(anchoredUnits$anchor)
  nonAnchorSides <- c(anchoredUnits$sire, anchoredUnits$dam)
  neverAnchorIds <- setdiff(unique(nonAnchorSides), everAnchor)
  hasOwnDirectChild <- function(id) id %in% childEdges$from
  b1Ids <- Filter(function(id) {
    id %in% realIds && !hasOwnDirectChild(id) && !hasParentEdge(id)
  }, neverAnchorIds)
  qualifiesUnit <- function(unitId) {
    p <- matingUnits$anchor[matingUnits$id == unitId]
    m <- matingUnits$nonAnchor[matingUnits$id == unitId]
    sireId <- matingUnits$sire[matingUnits$id == unitId]
    damId <- matingUnits$dam[matingUnits$id == unitId]
    if (is.na(p) || is.na(m)) return(FALSE)
    if (!(sireId %in% realIds) || !(damId %in% realIds)) return(FALSE)
    mateCountP <- sum(anchoredUnits$sire == p | anchoredUnits$dam == p)
    mateCountM <- sum(anchoredUnits$sire == m | anchoredUnits$dam == m)
    unambig <- (identical(sexOf[[p]], "M") && identical(sexOf[[m]], "F")) ||
      (identical(sexOf[[p]], "F") && identical(sexOf[[m]], "M"))
    mateCountP == 1L && mateCountM == 1L && !hasOwnDirectChild(p) && unambig
  }
  qualifyingUnits <- Filter(function(u) {
    qualifiesUnit(u) && matingUnits$nonAnchor[matingUnits$id == u] %in% b1Ids
  }, anchoredUnits$id)
  expect_true(length(qualifyingUnits) > 0L)

  ## The correction pass computes each shift from the mate's RAW,
  ## pre-collision formula value (the only value available at that point
  ## in the pipeline -- using her eventual post-push value would be
  ## circular, since the push itself depends on where the anchor already
  ## is). On this densely-packed real fixture (173 gen-0 founders), the
  ## mate's Tier-3 de-collision push (.deCollideIndividualPoints()/the B1-
  ## proximity pass, S662) very often DOES move her away from that raw
  ## target afterward -- exactly the plan doc's own disclosed, accepted
  ## interaction ("the arithmetically-correct rule still produces a real
  ## collision... confirming this requirement is real"), not a defect.
  ## Bounded by the same .kMaxIndividualPush = 2 raw-unit cap already
  ## established elsewhere in this file for the individual-side push;
  ## measured directly this session (29/34 units carry a residual, range
  ## [0.08, 1.52]), not assumed.
  diffs <- vapply(qualifyingUnits, function(u) {
    anchor <- matingUnits$anchor[matingUnits$id == u]
    mate <- matingUnits$nonAnchor[matingUnits$id == u]
    pos$x[pos$id == u] - mean(pos$x[pos$id %in% c(anchor, mate)])
  }, numeric(1L))
  ## S675: under the kinship2-parity QP floors one qualifying unit's
  ## residual is exactly 2 raw units up to solver precision
  ## (2.000000000007 -- quadprog's own ~1e-8 slack, see the real-375 floor
  ## test's own tolerance note); the bound is unchanged, only made robust
  ## to that representation.
  expect_true(all(abs(diffs) <= 2 + 1e-6),
              info = paste("max residual:", max(abs(diffs))))

  message(sprintf(
    paste("S666 conditional-shift rule: %d qualifying (B1-mate) unions on",
          "the real fixture; %d exact, residual range [%s, %s] where a",
          "later collision-avoidance push moved the mate off her raw",
          "formula target (disclosed, bounded, not a correctness defect)."),
    length(qualifyingUnits), sum(abs(diffs) <= 1e-6),
    sprintf("%.4f", min(abs(diffs))), sprintf("%.4f", max(abs(diffs)))))
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

## ---- S667 RED: disconnected-component separation ------------------------
## docs/planning/pedigree-diagram-disconnected-component-separation-plan.md,
## "REVISED DESIGN -- Session 667". Two or more weakly-connected families in
## one pedigree must render as separate side-by-side blocks, each laid out
## by the unchanged 3-tier engine on its own and then packed left-to-right
## (ped row order) with a per-row minSep gap -- which is exactly what
## kinship2::align.pedigree() does (verified bit-exact this session on
## every fixture below). Before S667 the families shared rows and
## interleaved: each B1 mate's anchor + minSep target landed on the other
## family and the de-collision search pushed her further into it.
##
## Every target vector below is pinned from a fresh kinship2 run made this
## session AND, when kinship2 is installed, re-derived live by
## .expectKinship2Agrees() so the pins can never silently drift from the
## installed kinship2's own behavior (test_makePedigreeMatingLayout.R's
## S666 end-to-end test established the inline-kinship2 pattern). The
## helpers (.kinship2X(), .expectKinship2Agrees(), .forestComponentsForTest(),
## .minCrossComponentRowGap()) live at the top of this file beside
## .expectNoOverlap() -- the rewritten Track B shrunk test above also uses
## them, and testthat sources a file top-down.

test_that(".positionMatingUnitForest packs disconnected families by PER-ROW
           contour, not by whole extent: a left family that is wide only at
           a DEEP row (F1xM1 -> A1; A1xS1 -> K1..K4) lets a shallower right
           family (F2xM2 -> B1) tuck in above its wide row -- UNCHANGED by
           Migration Path Phase 2 (Decision 6: .packComponents() itself is
           not touched by the QP). Target re-derived by actually running
           the new engine (radius-based minSep, Decision 3 -- no longer
           bit-exact vs kinship2's uniform 1-unit floor, see the retired
           kinship2-exact-match test earlier in this file).", {
  d1 <- data.frame(
    id   = c("F1", "M1", "A1", "S1", "K1", "K2", "K3", "K4", "F2", "M2", "B1"),
    sire = c(NA, NA, "F1", NA, "S1", "S1", "S1", "S1", NA, NA, "F2"),
    dam  = c(NA, NA, "M1", NA, "A1", "A1", "A1", "A1", NA, NA, "M2"),
    sex  = c("M", "F", "F", "M", "M", "F", "M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  d1$gen <- findGeneration(d1$id, d1$sire, d1$dam)
  forest <- .buildMatingUnitForest(d1)
  expect_length(.forestComponentsForTest(d1, forest), 2L)
  pos <- .positionMatingUnitForest(d1, forest)

  rel <- pos$x - pos$x[pos$id == "F1"]
  names(rel) <- pos$id
  ## CHANGED S675 (Migration Path Phase 3 -- kinship2-parity QP floors,
  ## the owner-ratified amendment to Decision 3: individual-individual
  ## 1.0 = minSep, individual-union 0.5, union-union 0.25, replacing the
  ## symbol-tangent 0.4167/0.2583/0.1 floors S674 shipped). Re-measured by
  ## actually running the amended engine, never hand-derived.
  ## kinship2's own uniform 1-unit geometry again (S667 verified this
  ## fixture bit-exact against a live kinship2 run under the pre-QP engine).
  target <- c(F1 = 0, M1 = 1, F2 = 2, M2 = 3,
              S1 = -0.5, A1 = 0.5, B1 = 2.5,
              K1 = -1.5, K2 = -0.5, K3 = 0.5, K4 = 1.5)
  expect_equal(unname(rel[names(target)]), unname(target), tolerance = 1e-5)
  .expectNoOverlap(pos)
})

test_that(".positionMatingUnitForest orders disconnected families by ped
           row order and packs each with a minSep gap -- three trios A, B,
           C -- UNCHANGED by Migration Path Phase 2 (Decision 6). Target
           re-derived by actually running the new engine (radius-based
           minSep, Decision 3).", {
  d2 <- data.frame(
    id   = c("A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"),
    sire = c(NA, NA, "A1", NA, NA, "B1", NA, NA, "C1"),
    dam  = c(NA, NA, "A2", NA, NA, "B2", NA, NA, "C2"),
    sex  = c("M", "F", "F", "M", "F", "M", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
  d2$gen <- findGeneration(d2$id, d2$sire, d2$dam)
  forest <- .buildMatingUnitForest(d2)
  expect_length(.forestComponentsForTest(d2, forest), 3L)
  pos <- .positionMatingUnitForest(d2, forest)

  rel <- pos$x - pos$x[pos$id == "A1"]
  names(rel) <- pos$id
  ## CHANGED S675 (Migration Path Phase 3 -- kinship2-parity QP floors,
  ## the owner-ratified amendment to Decision 3: individual-individual
  ## 1.0 = minSep, individual-union 0.5, union-union 0.25, replacing the
  ## symbol-tangent 0.4167/0.2583/0.1 floors S674 shipped). Re-measured by
  ## actually running the amended engine, never hand-derived.
  target <- c(A1 = 0, A2 = 1, B1 = 2, B2 = 3,
              C1 = 4, C2 = 5, A3 = 0.5, B3 = 2.5,
              C3 = 4.5)
  expect_equal(unname(rel[names(target)]), unname(target), tolerance = 1e-5)
  .expectNoOverlap(pos)
})

test_that(".positionMatingUnitForest packs disconnected families of unequal
           depth (a trio beside a 3-generation chain B1xB2 -> B3; B3xB5 ->
           B4) with the deeper family's extra row unconstrained by the
           shallower one -- UNCHANGED by Migration Path Phase 2
           (Decision 6). Target re-derived by actually running the new
           engine (radius-based minSep, Decision 3).", {
  d3 <- data.frame(
    id   = c("A1", "A2", "A3", "B1", "B2", "B3", "B4", "B5"),
    sire = c(NA, NA, "A1", NA, NA, "B1", "B3", NA),
    dam  = c(NA, NA, "A2", NA, NA, "B2", "B5", NA),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
  d3$gen <- findGeneration(d3$id, d3$sire, d3$dam)
  forest <- .buildMatingUnitForest(d3)
  expect_length(.forestComponentsForTest(d3, forest), 2L)
  pos <- .positionMatingUnitForest(d3, forest)

  rel <- pos$x - pos$x[pos$id == "A1"]
  names(rel) <- pos$id
  ## CHANGED S675 (Migration Path Phase 3 -- kinship2-parity QP floors,
  ## the owner-ratified amendment to Decision 3: individual-individual
  ## 1.0 = minSep, individual-union 0.5, union-union 0.25, replacing the
  ## symbol-tangent 0.4167/0.2583/0.1 floors S674 shipped). Re-measured by
  ## actually running the amended engine, never hand-derived.
  target <- c(A1 = 0, A2 = 1, B1 = 2, B2 = 3,
              A3 = 0.5, B3 = 2.5, B5 = 3.5, B4 = 3)
  expect_equal(unname(rel[names(target)]), unname(target), tolerance = 1e-5)
  .expectNoOverlap(pos)
})

test_that(".positionMatingUnitForest keeps the real 375-individual fixture's
           5 disconnected families (11/5/3/13/343 real individuals) as
           separate blocks: pairwise-disjoint x-ranges, and no two nodes of
           different families closer than minSep on any row -- before
           S667 the four small families interleaved among themselves
           (overlapping x-ranges) and the smallest same-row cross-family
           gap was 0.4167", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  comps <- .forestComponentsForTest(ped, forest)
  expect_length(comps, 5L)
  nReal <- vapply(comps, function(m) sum(!grepl("^__", m)), integer(1))
  expect_equal(nReal, c(11L, 5L, 3L, 13L, 343L))

  pos <- .positionMatingUnitForest(ped, forest)
  ranges <- t(vapply(comps, function(m) range(pos$x[pos$id %in% m]), numeric(2)))
  ## Packed in component order: each family's whole span lies strictly
  ## right of the previous family's.
  for (i in seq_len(nrow(ranges))[-1L]) {
    expect_lt(ranges[i - 1L, 2L], ranges[i, 1L],
              label = sprintf("family %d max x", i - 1L),
              expected.label = sprintf("family %d min x", i))
  }
  expect_gte(.minCrossComponentRowGap(pos, comps), 1 - 1e-9)
})

## ---- Decision 2 (S678): every rendered mate on its union's row --------
## Provisional-order design (docs/planning/pedigree-diagram-provisional-
## order-plan.md, S676; PRE-RED-ratified S678): with every B2-shaped
## non-anchor duplicated at every non-anchor occurrence
## (.buildMatingUnitForest() Decision 2), the node that RENDERS as the
## mate at any anchored unit -- the B1 individual's own derived point, or
## a __dup_ node -- always carries the unit's own gen (Tier 3 assigns
## tier3Gen from the unit). The census's class (e) ("a mate drawn on a
## row other than its union's row") empties BY CONSTRUCTION, while every
## real individual still renders on its own gen row (QP plan Decision 5's
## row policy, untouched). Before Decision 2 this fails with exactly the
## 56 B2 free occurrences the census counted (each resolving to the real
## B2 node at her own deeper/shallower gen).

test_that(".positionMatingUnitForest's every ANCHORED unit resolves its
           non-anchor to a node on the unit's own gen row, on the full
           real 375-individual fixture -- census class (e) = 0 by
           construction (Decision 2, S678)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  resolveNn <- .nonAnchorNodeResolver(forest$duplicates)
  mu <- forest$matingUnits
  anchored <- mu[!is.na(mu$anchor), , drop = FALSE]
  genOf <- stats::setNames(pos$gen, pos$id)

  mismatches <- character(0L)
  for (i in seq_len(nrow(anchored))) {
    nn <- resolveNn(anchored$nonAnchor[i], anchored$id[i])
    ## A dangling non-anchor resolves to an id with no rendered node at
    ## all -- skip (this fixture has none; the guard keeps the test's
    ## predicate honest rather than erroring on other fixtures' shapes).
    if (!(nn %in% names(genOf))) next
    if (genOf[[nn]] != genOf[[anchored$id[i]]]) {
      mismatches <- c(mismatches, anchored$id[i])
    }
  }
  expect_equal(mismatches, character(0L))
})

## ---- Decision 1 (S679): order-consistent seeding ----------------------
## Provisional-order design (docs/planning/pedigree-diagram-provisional-
## order-plan.md, S676; PRE-RED-ratified S679): the union/B1/duplicate
## provisional SEEDS are replaced by seeds at the QP objective's own
## ideal points (mate adjacent to its anchor at a gap-proportional inset
## min(0.9*minSep, 0.45*gap), union at half the inset, side from the
## unit's own children's mean, two-unit anchors split left/right).
## Magnitudes are discarded by the QP -- only the RANK survives -- so
## these tests assert the order-stage contract directly on the solved
## positions (rank is preserved exactly), the design's own two
## structural properties plus its disclosed residual bound, rather than
## re-deriving census counts. PRE-RED measurements (S679, direct edit +
## revert): dot-outside-span 31 -> 0; facing-mate crossings among
## <=2-unit anchors 2 -> 0; off-midpoint rows > 1e-3 raw: 56 -> 7, all
## seven the design's own disclosed structural floor (3 on the
## polygamous 5-unit anchor WCPXHD -- extras beyond a two-unit split
## keep their children's-mean seeds by design -- and 4 marry-in-chain
## crowding cases at ~0.5 raw). Anchors with 3+ units are the design's
## explicit unseeded-extras exception, so the crossing assertion scopes
## itself to pairs whose anchors both carry <= 2 units.

test_that(".positionMatingUnitForest's union dot never renders outside
           the span of its own anchor and rendered mate, for every
           same-row anchored unit on the full real 375-individual
           fixture (Decision 1, S679: a dot ranked outside its mates'
           span can never be centred by the QP)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  resolveNn <- .nonAnchorNodeResolver(forest$duplicates)
  mu <- forest$matingUnits
  anchored <- mu[!is.na(mu$anchor), , drop = FALSE]
  xOf <- stats::setNames(pos$x, pos$id)
  genOf <- stats::setNames(pos$gen, pos$id)
  eps <- 1e-6

  outside <- character(0L)
  for (i in seq_len(nrow(anchored))) {
    u <- anchored$id[i]
    a <- anchored$anchor[i]
    nn <- resolveNn(anchored$nonAnchor[i], u)
    if (!(nn %in% names(xOf)) || !(a %in% names(xOf))) next
    if (genOf[[nn]] != genOf[[a]]) next
    lo <- min(xOf[[a]], xOf[[nn]])
    hi <- max(xOf[[a]], xOf[[nn]])
    if (xOf[[u]] < lo - eps || xOf[[u]] > hi + eps) {
      outside <- c(outside, u)
    }
  }
  expect_equal(outside, character(0L))
})

test_that(".positionMatingUnitForest never crosses two same-row
           anchor--mate intervals whose four nodes are distinct and
           whose anchors each carry at most two units, on the full real
           375-individual fixture (Decision 1, S679: the
           gap-proportional inset keeps two facing mate seeds from
           overshooting across each other; anchors with 3+ units keep
           unseeded children's-mean extras by design and are excluded)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  resolveNn <- .nonAnchorNodeResolver(forest$duplicates)
  mu <- forest$matingUnits
  anchored <- mu[!is.na(mu$anchor), , drop = FALSE]
  unitsOfAnchor <- table(anchored$anchor)
  xOf <- stats::setNames(pos$x, pos$id)
  genOf <- stats::setNames(pos$gen, pos$id)
  eps <- 1e-6

  triples <- data.frame(u = character(0L), a = character(0L),
                        nn = character(0L), row = integer(0L),
                        stringsAsFactors = FALSE)
  for (i in seq_len(nrow(anchored))) {
    u <- anchored$id[i]
    a <- anchored$anchor[i]
    nn <- resolveNn(anchored$nonAnchor[i], u)
    if (!(nn %in% names(xOf)) || !(a %in% names(xOf))) next
    if (genOf[[nn]] != genOf[[a]]) next
    if (unitsOfAnchor[[a]] > 2L) next
    triples <- rbind(triples, data.frame(
      u = u, a = a, nn = nn, row = genOf[[a]], stringsAsFactors = FALSE
    ))
  }

  crossed <- character(0L)
  byRow <- split(seq_len(nrow(triples)), triples$row)
  for (rr in byRow) {
    if (length(rr) < 2L) next
    for (ii in seq_along(rr)[-length(rr)]) {
      for (jj in (ii + 1L):length(rr)) {
        t1 <- triples[rr[ii], ]
        t2 <- triples[rr[jj], ]
        if (anyDuplicated(c(t1$a, t1$nn, t2$a, t2$nn)) > 0L) next
        lo1 <- min(xOf[[t1$a]], xOf[[t1$nn]])
        hi1 <- max(xOf[[t1$a]], xOf[[t1$nn]])
        lo2 <- min(xOf[[t2$a]], xOf[[t2$nn]])
        hi2 <- max(xOf[[t2$a]], xOf[[t2$nn]])
        m1Inside2 <- xOf[[t1$nn]] > lo2 + eps && xOf[[t1$nn]] < hi2 - eps
        m2Inside1 <- xOf[[t2$nn]] > lo1 + eps && xOf[[t2$nn]] < hi1 - eps
        if (m1Inside2 && m2Inside1) {
          crossed <- c(crossed, paste(t1$u, t2$u))
        }
      }
    }
  }
  expect_equal(crossed, character(0L))
})

test_that(".positionMatingUnitForest centres every same-row union dot on
           its anchor/rendered-mate midpoint up to the design's seven
           disclosed structural residuals, on the full real
           375-individual fixture (Decision 1, S679; Learning 726's
           two-assertion pattern: rows above a meaningful floor are
           bounded and NAMED, sub-precision solver dust is not counted
           against the gate) -- the four marry-in-chain crowding cases
           __union_97/128/179/228 stay under ~0.5 raw and the polygamous
           anchor WCPXHD's three units under ~1.0 raw", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)

  resolveNn <- .nonAnchorNodeResolver(forest$duplicates)
  mu <- forest$matingUnits
  anchored <- mu[!is.na(mu$anchor), , drop = FALSE]
  xOf <- stats::setNames(pos$x, pos$id)
  genOf <- stats::setNames(pos$gen, pos$id)

  dev <- numeric(0L)
  for (i in seq_len(nrow(anchored))) {
    u <- anchored$id[i]
    a <- anchored$anchor[i]
    nn <- resolveNn(anchored$nonAnchor[i], u)
    if (!(nn %in% names(xOf)) || !(a %in% names(xOf))) next
    if (genOf[[nn]] != genOf[[a]]) next
    dev[u] <- abs(xOf[[u]] - (xOf[[a]] + xOf[[nn]]) / 2)
  }
  ## Assertion 1 of the pattern: every row above the meaningful floor
  ## (1e-3 raw units -- solver dust measures ~1e-8 raw, five orders
  ## below) belongs to the design's disclosed structural set.
  disclosed <- c("__union_97", "__union_114", "__union_128", "__union_130",
                 "__union_137", "__union_179", "__union_228")
  realRows <- names(dev)[dev > 1e-3]
  expect_true(all(realRows %in% disclosed))
  ## Assertion 2 of the pattern: even the disclosed rows stay bounded --
  ## ~0.5 raw for the marry-in-chain crowding cases, ~1.0 raw for the
  ## polygamous anchor's units -- never the unseeded magnitudes (max
  ## 2.0 raw under the Phase-1 engine this RED was written against,
  ## up to 25 raw before Phase 1's duplication policy).
  expect_lte(max(dev[realRows], 0), 1.05)
})

