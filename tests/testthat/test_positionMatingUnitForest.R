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

## ---- basic trio: union x is the midpoint of its 2 parents' x ----------

test_that(".positionMatingUnitForest positions a simple 2-parent/3-child
           trio with the union's x at the midpoint of its 2 parents, and
           3 distinct, non-overlapping child x positions one gen below", {
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

  p1x <- pos$x[pos$id == "P1"]; p2x <- pos$x[pos$id == "P2"]
  unionX <- pos$x[pos$id == forest$matingUnits$id]
  expect_equal(unionX, (p1x + p2x) / 2)

  childX <- pos$x[pos$id %in% c("C1", "C2", "C3")]
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
           fixture (8LKBV9 anchors 1 of 3 mating units, duplicated at the
           other 2) without overlap, with each duplicate's gen matching ITS
           OWN mating unit's gen (issue #143 fix -- not uniformly 8LKBV9's
           own real gen, since the 2 units he's duplicated at have
           different gens: max(8LKBV9=1, 8P17E3=0)=1 and
           max(8LKBV9=1, FJIB3R=2)=2)", {
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
  expect_equal(nrow(kDup), 2L)

  unit3 <- forest$matingUnits$id[forest$matingUnits$dam == "8P17E3"]
  unit4 <- forest$matingUnits$id[forest$matingUnits$dam == "FJIB3R"]
  dupAt3 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit3]
  dupAt4 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit4]
  expect_equal(pos$gen[pos$id == dupAt3], 1L)  # unit3's own gen
  expect_equal(pos$gen[pos$id == dupAt4], 2L)  # unit4's own gen -- CHANGED
                                                # from the pre-fix formula
                                                # (8LKBV9's own gen, 1L)

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
## issue #144 fix (this session): this SAME fixture also embeds one of the
## 51 real-fixture anchor-side mismatches -- 8P17E3 anchors the unit3 union
## (dam="8P17E3") at unitGen=1, but her own raw ped$gen is 0. The #144 fix
## (docs/planning/issue144-anchor-row-mismatch-fix-plan.md, Candidate B:
## effGenOf) moves her DISPLAYED gen to 1 (matching her unit), leaving her
## x (2.00, computed purely from mergeSubtrees(), never from ownGen)
## unchanged -- empirically confirmed this session against a patched
## 3-edit prototype. Every other id/union/duplicate value below is
## unaffected by #144 (none of them anchor a mismatched unit in this
## fixture) -- re-confirmed unchanged against the same prototype.

test_that(".positionMatingUnitForest's exact x/gen values for the real
           GA204Z/8LKBV9 loop fixture catch a desynchronized (only one of
           the two) issue #143 fix, and reflect issue #144's anchor-side
           effGenOf correction for 8P17E3 -- not just the corrected gen
           values alone", {
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

  expectPos("5A6DFT", 0.00, 0L)
  expectPos("8DKELJ", -0.50, 0L)
  expectPos("G8EBU9", 0.00, 1L)  # CHANGED from (0.25, 0L), issue #143
  expectPos("8P17E3", 2.00, 1L)  # gen CHANGED from 0L, issue #144 (she
                                 # anchors unit3, unitGen=1); x unaffected
  expectPos("8LKBV9", 0.50, 1L)
  expectPos("FJIB3R", 1.00, 2L)
  expectPos("9VGCCV", 2.00, 2L)
  expectPos("GA204Z", 1.00, 3L)

  unit1 <- forest$matingUnits$id[forest$matingUnits$sire == "5A6DFT"]
  unit2 <- forest$matingUnits$id[forest$matingUnits$dam == "G8EBU9"]
  unit3 <- forest$matingUnits$id[forest$matingUnits$dam == "8P17E3"]
  unit4 <- forest$matingUnits$id[forest$matingUnits$dam == "FJIB3R"]
  expectPos(unit1, -0.25, 0L)
  expectPos(unit2, 0.25, 1L)
  expectPos(unit3, 2.20, 1L)
  expectPos(unit4, 1.20, 2L)

  dupAt3 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit3]
  dupAt4 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit4]
  ## Both duplicates' x shifts from baseline (2.65, 1.65) -- Edit 1's
  ## contour move for G8EBU9 cascades through the whole tree's layout, not
  ## just her own position -- but only dupAt4's gen visibly changes (1
  ## -> 2); dupAt3's gen coincidentally matches its unit's gen either way.
  expectPos(dupAt3, 2.40, 1L)  # x CHANGED from 2.65; gen unaffected
  expectPos(dupAt4, 1.40, 2L)  # x CHANGED from 1.65; gen CHANGED from 1L
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
  expect_equal(nrow(pos), 740L)  # 375 + 128 + 237, Slice 1's own §7 figures
  expect_false(any(is.na(pos$x)))
  expect_false(any(is.na(pos$gen)))
  .expectNoOverlap(pos)
})

## ---- gen semantics: every node's gen matches its source-of-truth ------

test_that(".positionMatingUnitForest's gen column matches each occurrence's
           CORRECTED source of truth (issues #143/#144): a FREE-PASS or
           DUPLICATE occurrence's own MATING UNIT's gen (issue #143 --
           previously every occurrence used its own ped$gen uniformly,
           which mis-positioned any non-anchor occurrence whose personal
           gen differed from its mating unit's gen), an ANCHOR's own
           EFFECTIVE gen -- max(own ped$gen, every unit gen it anchors)
           (issue #144 -- previously an anchor's raw ped$gen was used
           unconditionally, which mis-positioned an anchor whose personal
           gen was SHALLOWER than the unit(s) it anchors), and a mating
           unit's already-verified max(parent gens) from Slice 1", {
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
  ## unit parent). Anchors' EFFECTIVE gen is max(own ped$gen, the gen of
  ## every unit they anchor) (issue #144) -- hand-verified against
  ## forest$matingUnits$anchor/gen this session: 5A6DFT/8P17E3/8LKBV9/
  ## FJIB3R each anchor exactly the one unit they belong to;
  ## 9VGCCV/GA204Z are non-parent children, never sire/dam of any unit.
  expect_equal(pos$gen[pos$id == "5A6DFT"], 0L)
  ## 8P17E3 anchors unit3 (dam="8P17E3"), unitGen=max(8LKBV9=1,8P17E3=0)=1
  ## -- her own raw gen (0) is SHALLOWER, so her effective gen is 1L.
  ## CHANGED from 0L, issue #144.
  expect_equal(pos$gen[pos$id == "8P17E3"], 1L)
  expect_equal(pos$gen[pos$id == "8LKBV9"], 1L)
  expect_equal(pos$gen[pos$id == "FJIB3R"], 2L)
  expect_equal(pos$gen[pos$id == "9VGCCV"], 2L)
  expect_equal(pos$gen[pos$id == "GA204Z"], 3L)

  ## 8DKELJ is free-pass, but her one unit's gen (max(5A6DFT=0, 8DKELJ=0))
  ## already equals her own gen -- no VISIBLE change, still 0.
  expect_equal(pos$gen[pos$id == "8DKELJ"], 0L)

  ## G8EBU9 is free-pass and mismatched: her own gen is 0, but her one
  ## unit's gen (max(8LKBV9=1, G8EBU9=0)) is 1 -- CHANGES from the pre-fix
  ## 0.
  expect_equal(pos$gen[pos$id == "G8EBU9"], 1L)

  ## Duplicates: each duplicate's gen is now its OWN mating unit's gen, not
  ## 8LKBV9's personal gen (1) uniformly -- one coincidentally still 1
  ## (its unit's gen matches 8LKBV9's own gen), the other CHANGES to 2.
  unit3 <- forest$matingUnits$id[forest$matingUnits$dam == "8P17E3"]
  unit4 <- forest$matingUnits$id[forest$matingUnits$dam == "FJIB3R"]
  dupAt3 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit3]
  dupAt4 <- forest$duplicates$id[forest$duplicates$matingUnitId == unit4]
  expect_equal(pos$gen[pos$id == dupAt3], 1L)
  expect_equal(pos$gen[pos$id == dupAt4], 2L)  # CHANGED from 1L

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

## ---- issue #144 §6 dragon: the one residual the fix does not close -----
## (an anchor anchoring 2+ mating units at genuinely DIFFERENT unitGen
## values, or a single-unit anchor with a D5 direct child shallower than
## its own relocated effGen). Neither shape occurs in either bundled real
## fixture (docs/planning/issue144-anchor-row-mismatch-fix-plan.md §6) --
## these are new, purpose-built synthetic fixtures asserting deterministic,
## non-crashing, non-NA behavior, not a fix for the residual itself (out of
## scope by design, plan §8). Both fixtures independently constructed and
## verified this session against a patched 3-edit prototype before being
## committed here.

test_that(".positionMatingUnitForest handles an anchor that anchors 2
           mating units at differing unitGen without crashing or producing
           NA -- effGenOf's max() rule resolves the DEEPER unit but
           RELOCATES (does not eliminate) the mismatch to the SHALLOWER
           one, net anchor-mismatch count unchanged (plan §6(a))", {
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

  ## Confirm this fixture's own premise before testing the residual: HUB
  ## anchors BOTH units (via 2 pre-seeded elimination/preference wins), at
  ## genuinely different unitGen (1 and 5).
  unitShallow <- forest$matingUnits$id[forest$matingUnits$sire == "HUB" &
                                          forest$matingUnits$dam == "MATE1"]
  unitDeep <- forest$matingUnits$id[forest$matingUnits$sire == "HUB" &
                                       forest$matingUnits$dam == "MATE2"]
  expect_equal(forest$matingUnits$anchor[forest$matingUnits$id == unitShallow],
               "HUB")
  expect_equal(forest$matingUnits$anchor[forest$matingUnits$id == unitDeep],
               "HUB")
  expect_equal(forest$matingUnits$gen[forest$matingUnits$id == unitShallow], 1L)
  expect_equal(forest$matingUnits$gen[forest$matingUnits$id == unitDeep], 5L)

  pos <- .positionMatingUnitForest(ped, forest)
  expect_false(any(is.na(pos$x)))
  expect_false(any(is.na(pos$gen)))
  .expectNoOverlap(pos)

  ## HUB's effective gen is max(own gen=1, unitShallow=1, unitDeep=5) = 5
  ## -- matches the deeper unit (resolved), mismatches the shallower one
  ## (relocated, not eliminated).
  expect_equal(pos$gen[pos$id == "HUB"], 5L)
})

test_that(".positionMatingUnitForest handles a single-unit anchor whose
           relocated effGen is DEEPER than a D5 direct child's own gen
           without crashing or producing NA -- the child renders 'above'
           (shallower than) its own now-relocated parent, a valid but
           visually-inverted layout the fix does not attempt to resolve
           (plan §6, widened residual trigger)", {
  ped <- data.frame(
    id   = c("ANCHOR", "MATE", "MATECHILD", "D5CHILD"),
    sire = c(NA, NA, "ANCHOR", "ANCHOR"),
    dam  = c(NA, NA, "MATE", NA),
    sex  = c("M", "F", "F", "M"),
    gen  = c(1L, 4L, 5L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  expect_equal(forest$matingUnits$anchor, "ANCHOR")
  expect_equal(forest$matingUnits$gen, 4L)

  pos <- .positionMatingUnitForest(ped, forest)
  expect_false(any(is.na(pos$x)))
  expect_false(any(is.na(pos$gen)))
  .expectNoOverlap(pos)

  ## ANCHOR's effective gen is max(own gen=1, unit gen=4) = 4 -- matches
  ## its unit (resolved). D5CHILD keeps its own gen (2), unaffected by the
  ## fix (D5 direct children are never in effGenOf's domain) -- shallower
  ## than its now-relocated parent.
  expect_equal(pos$gen[pos$id == "ANCHOR"], 4L)
  expect_equal(pos$gen[pos$id == "D5CHILD"], 2L)
})
