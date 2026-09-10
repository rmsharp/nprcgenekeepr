## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .solveJointQP() -- Pedigree Diagram Joint QP Solver (Option C),
## Migration Path Phase 1 (docs/planning/pedigree-diagram-joint-qp-solver-plan.md
## Sec. "Migration Path" > "Phase 1 -- .solveJointQP() standalone, not yet wired
## into production").
##
## Phase 1's own DONE criteria (plan doc): a standalone .solveJointQP() verified
## against small fixtures that carry NO known census defect (Track B full/shrunk,
## Track C, D1-D3) -- this phase's job is confirming the QP reproduces
## feasibility/order (Decision 3's hard minSep constraint is never violated,
## regardless of objective weighting), NOT fixing a defect and NOT pinning exact
## output x-values. Unlike most of this codebase's other pedigree-diagram tests,
## there is no independent ground-truth oracle (kinship2 has no equivalent joint
## solve over this project's own union/duplicate node set) to hand-derive a pinned
## target against -- so these tests assert the QP's own structural guarantees
## (Decisions 2/3/4), not specific coordinates. .solveJointQP() is NOT wired into
## .positionMatingUnitForest() at this phase (Phase 2's job) -- every fixture
## below is run through the UNCHANGED .positionMatingUnitForest() first, to
## produce the provisionalPos input .solveJointQP() consumes, exactly matching
## Decision 1's "Phase A output feeds Phase B" contract.

## ---- fixture builders (inline data.frames, matching this codebase's own
## convention -- no shared external fixture file exists; see
## test_positionMatingUnitForest.R) -------------------------------------------

## Track B full: 16-subject fixture (test_positionMatingUnitForest.R's own
## "full, non-shrunk 16-subject Track B fixture"). 4 qualifying anchored units,
## no duplicates.
.qpTrackBFull <- function() {
  ped <- data.frame(
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
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

## Track B shrunk: the same origin, shrunk to 8 individuals in 2 disconnected
## families (test_positionMatingUnitForest.R's own S667 fixture).
.qpTrackBShrunk <- function() {
  pedB <- .qpTrackBFull()
  genotypedB <- c(P1 = TRUE, P2 = TRUE, P3 = FALSE, P4 = FALSE, P5 = TRUE,
    P6 = TRUE, C1 = TRUE, C2 = FALSE, C3 = TRUE, C4 = TRUE, C4a = TRUE,
    G3 = FALSE, M1 = TRUE, L1 = TRUE, L2 = TRUE, L3 = TRUE)[pedB$id]
  affectedB <- c(P1 = NA, P2 = NA, P3 = NA, P4 = NA, P5 = NA, P6 = NA,
    C1 = FALSE, C2 = NA, C3 = TRUE, C4 = TRUE, C4a = TRUE, G3 = NA,
    M1 = TRUE, L1 = NA, L2 = FALSE, L3 = TRUE)[pedB$id]
  shrunk <- shrinkPedigree(pedB, genotypedB, affected = affectedB,
                           maxBits = 1L)$ped
  shrunk$gen <- findGeneration(shrunk$id, shrunk$sire, shrunk$dam)
  shrunk
}

## Track C: half-sib-mating convergent loop (F1 doubly-mated: F1xF2 -> A,
## F1xF3 -> B, AxB -> C). F1 never anchors (F2/F3 win anchor by lower
## mate-count), so F1 is a B1 free-pass individual via F1xF2 (its first,
## free non-anchor occurrence) and a real duplicate (__dup_F1_1) via F1xF3
## (its second) -- the only fixture below with both a B1 individual AND a
## real duplicate node, needed for the wDup sweep (case 4). S678
## (Decision 2, spouse duplication): B -- a B2-shaped non-anchor at the
## A x B unit (her own parent edge) -- now also gets __dup_B_1 there, so
## the case-4 sweep additionally exercises a kinship2-style
## spouse-duplicate against the wDup term.
.qpTrackC <- function() {
  data.frame(
    id = c("F1", "F2", "F3", "A", "B", "C"),
    sire = c(NA, NA, NA, "F1", "F1", "A"),
    dam = c(NA, NA, NA, "F2", "F3", "B"),
    sex = c("M", "F", "F", "M", "F", "M"),
    gen = c(0L, 0L, 0L, 1L, 1L, 2L),
    stringsAsFactors = FALSE
  )
}

## D1/D2/D3: the 3 synthetic multi-family (disconnected-component) fixtures
## from test_positionMatingUnitForest.R's own S667 section.
.qpD1 <- function() {
  ped <- data.frame(
    id   = c("F1", "M1", "A1", "S1", "K1", "K2", "K3", "K4", "F2", "M2", "B1"),
    sire = c(NA, NA, "F1", NA, "S1", "S1", "S1", "S1", NA, NA, "F2"),
    dam  = c(NA, NA, "M1", NA, "A1", "A1", "A1", "A1", NA, NA, "M2"),
    sex  = c("M", "F", "F", "M", "M", "F", "M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

.qpD2 <- function() {
  ped <- data.frame(
    id   = c("A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"),
    sire = c(NA, NA, "A1", NA, NA, "B1", NA, NA, "C1"),
    dam  = c(NA, NA, "A2", NA, NA, "B2", NA, NA, "C2"),
    sex  = c("M", "F", "F", "M", "F", "M", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

.qpD3 <- function() {
  ped <- data.frame(
    id   = c("A1", "A2", "A3", "B1", "B2", "B3", "B4", "B5"),
    sire = c(NA, NA, "A1", NA, NA, "B1", "B3", NA),
    dam  = c(NA, NA, "A2", NA, NA, "B2", "B5", NA),
    sex  = c("M", "F", "F", "M", "F", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

## Issue #154 orphan-unit fixture (both sire AND dam dangling) --
## test_positionMatingUnitForest.R's own fixture, reused verbatim (case 5).
.qpOrphanUnit <- function() {
  data.frame(
    id = "CHILD",
    sire = "DANGLING_SIRE",
    dam = "DANGLING_DAM",
    sex = "F",
    gen = 0L,
    stringsAsFactors = FALSE
  )
}

.qpSmallFixtures <- list(
  trackBFull = .qpTrackBFull,
  trackBShrunk = .qpTrackBShrunk,
  trackC = .qpTrackC,
  d1 = .qpD1,
  d2 = .qpD2,
  d3 = .qpD3
)

## Builds forest + provisionalPos (Decision 1's Phase A output, UNCHANGED --
## .positionMatingUnitForest() itself is not modified by Phase 1) for a given
## ped-building function.
.qpProvisional <- function(pedFn) {
  ped <- pedFn()
  forest <- .buildMatingUnitForest(ped)
  list(ped = ped, forest = forest,
       provisionalPos = .positionMatingUnitForest(ped, forest))
}

## ---- shared assertion helpers -----------------------------------------

## Decision 3's clearance table, reproduced here (not shared with R/ code --
## GREEN's own .solveJointQP() computes these independently; a test-side
## re-derivation, matching this codebase's own "assert against an
## independent computation, not the same formula" discipline elsewhere,
## e.g. .expectKinship2Agrees()).
##
## S675 AMENDMENT (Migration Path Phase 3, owner-ratified via
## AskUserQuestion after seeing the real 375-fixture render): the floors are
## SPACING values keyed to the engine's own minSep = 1, NOT the render-layer
## symbol-tangent clearances Decision 3 originally repurposed ((25+25)/120,
## (25+6)/120, (6+6)/120). Under those tangent floors the QP objective
## compressed 90% of the real fixture's adjacent individuals to exactly 50 px
## centre-to-centre (symbols touching, labels overlapping into a band) and
## the census's class (a) read 90 sub-microscopic (<= 1.3e-6 px) shortfalls
## at its 1e-9 px epsilon. kinship2's own alignped4 uses a uniform 1-unit
## floor; this table mirrors it: individual-individual = minSep (1.0),
## individual-union = minSep / 2 (the S666 qualifying-pair geometry, mates
## 1.0 apart with the dot centred), union-union = minSep / 4.
.qpMinSep <- 1
.qpUnionClearanceIndividual <- .qpMinSep / 2
.qpUnionClearanceUnion <- .qpMinSep / 4
.qpIndividualClearance <- .qpMinSep

.qpMinSepFor <- function(k1, k2) {
  if (k1 == "union" && k2 == "union") return(.qpUnionClearanceUnion)
  if (k1 == "union" || k2 == "union") return(.qpUnionClearanceIndividual)
  .qpIndividualClearance
}

## Case 3: the hard adjacent-pair minSep floor (Decision 3) is never
## violated, for every row (grouped by gen), in the fixed left-to-right
## order .solveJointQP()'s own output implies (sorted by its OWN x -- the
## QP may reorder relative spacing but Decision 3's own constraint
## construction is keyed to the PROVISIONAL order, so re-sorting by the
## solved x and checking adjacent gaps is the correct post-hoc check: if
## the QP is feasible, the solved order must match the provisional order
## exactly, and every adjacent gap must clear the floor).
.expectMinSepFloorHeld <- function(pos, matingUnits) {
  kind <- ifelse(pos$id %in% matingUnits$id, "union", "individual")
  names(kind) <- pos$id
  for (g in sort(unique(pos$gen))) {
    rowIds <- pos$id[pos$gen == g]
    if (length(rowIds) < 2L) next
    rowIds <- rowIds[order(pos$x[match(rowIds, pos$id)], rowIds,
                            method = "radix")]
    for (i in seq_len(length(rowIds) - 1L)) {
      a <- rowIds[i]
      b <- rowIds[i + 1L]
      gap <- pos$x[pos$id == b] - pos$x[pos$id == a]
      req <- .qpMinSepFor(kind[[a]], kind[[b]])
      testthat::expect_gte(gap, req - 1e-6)
    }
  }
}

## ---- case 6: dependency wired ------------------------------------------

test_that("quadprog is installed and solve.QP resolves (DESCRIPTION Imports:
           promotion, Migration Path Phase 1)", {
  expect_true(requireNamespace("quadprog", quietly = TRUE))
  expect_true(is.function(quadprog::solve.QP))
})

## ---- cases 1-3: node-set preservation / no-error / minSep floor, every
## small fixture ------------------------------------------------------------

for (fixtureName in names(.qpSmallFixtures)) {
  local({
    thisFixture <- fixtureName
    pedFn <- .qpSmallFixtures[[thisFixture]]

    test_that(sprintf(
      ".solveJointQP() preserves the provisional node set, runs without
       error, and never violates Decision 3's minSep floor -- %s fixture",
      thisFixture), {
      built <- .qpProvisional(pedFn)
      solved <- expect_error(
        .solveJointQP(built$provisionalPos, built$forest$matingUnits,
                      built$forest$duplicates, built$forest$childEdges),
        NA)

      ## Case 1: node-set preservation (Decision 2).
      expect_setequal(solved$id, built$provisionalPos$id)
      expect_equal(nrow(solved), nrow(built$provisionalPos))
      expect_true(all(is.finite(solved$x)))

      ## Case 3: minSep floor.
      .expectMinSepFloorHeld(solved, built$forest$matingUnits)
    })
  })
}

## ---- case 4: weight-sweep regression guard for wUnion/wDup (Decision 4's
## own "not assumed here" caveat; mirrors Learning 678's sweep methodology)
## --------------------------------------------------------------------------

test_that(".solveJointQP()'s minSep floor holds at every wUnion/wDup setting
           swept across several orders of magnitude -- Track C (has both a
           B1 individual and a real duplicate, __dup_F1_1) and Track B full",
          {
  sweepWeights <- c(0.01, 0.1, 1, 2, 10, 100)
  for (fixtureName in c("trackC", "trackBFull")) {
    built <- .qpProvisional(.qpSmallFixtures[[fixtureName]])
    for (w in sweepWeights) {
      solved <- expect_error(
        .solveJointQP(built$provisionalPos, built$forest$matingUnits,
                      built$forest$duplicates, built$forest$childEdges,
                      wUnion = w, wDup = w),
        NA,
        info = sprintf("fixture=%s wUnion=wDup=%s", fixtureName, w))
      .expectMinSepFloorHeld(solved, built$forest$matingUnits)
    }
  }
})

## ---- case 5: orphan-unit edge case (issue #154, Impact Analysis risk) ---

test_that(".solveJointQP() does not error on an orphan mating unit (both
           sire AND dam dangling, anchorOf NA) -- no spousal-pull/child-
           centering/union-centering terms apply to it (no real anchor/
           non-anchor pair exists), but its node is still present and
           finite, and the minSep floor still holds", {
  built <- .qpProvisional(.qpOrphanUnit)
  expect_true(is.na(built$forest$matingUnits$anchor[[1L]]))

  solved <- expect_error(
    .solveJointQP(built$provisionalPos, built$forest$matingUnits,
                  built$forest$duplicates, built$forest$childEdges),
    NA)

  expect_setequal(solved$id, built$provisionalPos$id)
  expect_true(all(is.finite(solved$x)))
  .expectMinSepFloorHeld(solved, built$forest$matingUnits)
})

## ---- cases 7-8: single-dangling-parent edge cases (Migration Path Phase 2,
## found live during wiring -- Phase 1's own 6 fixtures + the case-5 orphan
## (BOTH parents dangling) never exercised a unit with EXACTLY ONE dangling
## parent, a shape .positionMatingUnitForest()'s own production mating-unit
## population legitimately contains (test_positionMatingUnitForest.R:690's
## own dangling-parent fixture, reused verbatim below). anchoredUnits$anchor
## is always a real, rendered id (.buildMatingUnitForest() only ever assigns
## a real party as anchor), but nonAnchor can be a dangling id with no
## rendered node at all -- .nonAnchorNodeResolver() then returns that
## unresolved dangling id itself, outside the QP's own variable set. ------

## A single unit, anchor real, non-anchor a dangling parent's FREE (only)
## occurrence -- no duplicate entry exists for her at all.
.qpDanglingNonAnchor <- function() {
  data.frame(
    id = c("REAL_SIRE", "CHILD"),
    sire = c(NA, "REAL_SIRE"),
    dam = c(NA, "DANGLING_DAM"),
    sex = c("M", "F"),
    gen = c(0L, 1L),
    stringsAsFactors = FALSE
  )
}

test_that(".solveJointQP() does not error when a unit's non-anchor party is
           a dangling parent's FREE (non-duplicated) occurrence -- Nnode
           resolves to an id with no rendered node at all, so terms
           1/2/3 (spousal pull/child centering/union centering) must be
           skipped for that unit, mirroring the already-established
           orphan-unit exclusion (anchor == NA) generalized to \"anchor OR
           Nnode has no rendered node\"", {
  built <- .qpProvisional(.qpDanglingNonAnchor)
  expect_false("DANGLING_DAM" %in% built$provisionalPos$id)

  solved <- expect_error(
    .solveJointQP(built$provisionalPos, built$forest$matingUnits,
                  built$forest$duplicates, built$forest$childEdges),
    NA)

  expect_setequal(solved$id, built$provisionalPos$id)
  expect_true(all(is.finite(solved$x)))
  .expectMinSepFloorHeld(solved, built$forest$matingUnits)
})

## The SAME dangling parent at 2 mating units -- test_positionMatingUnitForest
## .R's own fixture, reused verbatim (matching this codebase's own reuse
## convention). S682: the forest no longer mints a __dup_ for a dangling
## parent (see test_buildMatingUnitForest.R's amended policy block), so the
## dangling-realId duplicate shape is hand-built below instead --
## .solveJointQP() takes 'duplicates' as a plain argument, and term 4's
## dangling-realId skip (S673) must stay robust to a direct caller handing
## it that legacy shape.
.qpDanglingDuplicateRealId <- function() {
  data.frame(
    id = c("SIRE1", "SIRE2", "CHILD1", "CHILD2"),
    sire = c(NA, NA, "SIRE1", "SIRE2"),
    dam = c(NA, NA, "DANGLING_DAM", "DANGLING_DAM"),
    sex = c("M", "M", "F", "M"),
    gen = c(0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
}

test_that(".solveJointQP() does not error when a duplicate node's own realId
           is a dangling parent with no rendered node -- the S682 forest
           policy no longer produces this shape (asserted here), but term
           4's dangling-realId skip (S673) stays exercised with the legacy
           duplicates row and its positioned node hand-built, since
           .solveJointQP() accepts 'duplicates' directly", {
  built <- .qpProvisional(.qpDanglingDuplicateRealId)
  ## S682 policy: no __dup_ minted for the dangling parent at 2 units.
  expect_equal(nrow(built$forest$duplicates), 0L)
  expect_false("DANGLING_DAM" %in% built$provisionalPos$id)

  ## Hand-build the legacy shape the pre-S682 forest produced: a __dup_
  ## node at the second unit whose realId is the dangling, unrendered id.
  unit2Id <- built$forest$matingUnits$id[2L]
  legacyDups <- data.frame(id = "__dup_DANGLING_DAM_1",
                           realId = "DANGLING_DAM",
                           matingUnitId = unit2Id,
                           stringsAsFactors = FALSE)
  dupNodeRow <- built$provisionalPos[
    built$provisionalPos$id == unit2Id, , drop = FALSE]
  dupNodeRow$id <- legacyDups$id
  dupNodeRow$x <- dupNodeRow$x + 1
  pos <- rbind(built$provisionalPos, dupNodeRow)

  solved <- expect_error(
    .solveJointQP(pos, built$forest$matingUnits,
                  legacyDups, built$forest$childEdges),
    NA)

  expect_setequal(solved$id, pos$id)
  expect_true(all(is.finite(solved$x)))
  .expectMinSepFloorHeld(solved, built$forest$matingUnits)
})

## ---- S675: Migration Path Phase 3 -- kinship2-parity floor amendment ----

## The adjacent-pair gaps of one solved component, by pair kind, in the
## solved left-to-right order per row (same walk as .expectMinSepFloorHeld,
## returning the gaps rather than asserting on them).
.qpAdjacentGaps <- function(pos, matingUnits) {
  kind <- ifelse(pos$id %in% matingUnits$id, "U", "I")
  names(kind) <- pos$id
  out <- list(II = numeric(0L), IU = numeric(0L), UU = numeric(0L))
  for (g in sort(unique(pos$gen))) {
    rowIds <- pos$id[pos$gen == g]
    if (length(rowIds) < 2L) next
    rowIds <- rowIds[order(pos$x[match(rowIds, pos$id)], rowIds,
                            method = "radix")]
    x <- pos$x[match(rowIds, pos$id)]
    for (i in seq_len(length(rowIds) - 1L)) {
      k <- paste(sort(c(kind[[rowIds[i]]], kind[[rowIds[i + 1L]]])),
                 collapse = "")
      out[[k]] <- c(out[[k]], x[i + 1L] - x[i])
    }
  }
  out
}

for (fixtureName in c("trackC", "trackBFull")) {
  local({
    thisFixture <- fixtureName
    pedFn <- .qpSmallFixtures[[thisFixture]]

    test_that(sprintf(
      ".solveJointQP() spaces adjacent individuals at least minSep = 1.0
       apart (kinship2's own uniform floor), individual-union pairs at
       least 0.5, union-union pairs at least 0.25 -- and the binding
       individual-individual gap sits exactly on that 1.0 floor (the
       objective still compresses to the constraint, as S673's sweep
       found for the original floors) -- S675 amendment to Decision 3,
       %s fixture", thisFixture), {
      built <- .qpProvisional(pedFn)
      solved <- .solveJointQP(built$provisionalPos,
                              built$forest$matingUnits,
                              built$forest$duplicates,
                              built$forest$childEdges)
      gaps <- .qpAdjacentGaps(solved, built$forest$matingUnits)
      expect_gt(length(gaps$II), 0L)
      expect_gt(length(gaps$IU), 0L)
      expect_true(all(gaps$II >= 1.0 - 1e-9))
      expect_true(all(gaps$IU >= 0.5 - 1e-9))
      expect_true(all(gaps$UU >= 0.25 - 1e-9))
      expect_equal(min(gaps$II), 1.0, tolerance = 1e-6)
    })
  })
}

## ---- S683: term 4 skips spouse (B2) duplicates -------------------------
## Owner-ratified amendment to the S675 no-weight-tuning mandate (the
## wDup-on-spouse-duplicates BACKLOG item; provisional-order design Open
## Question 2 resolved): the duplicate-proximity term applies ONLY to
## polygamy (B1) duplicates -- a duplicate whose realId is B2-shaped (an
## own parent edge, or an own single-parent direct child; the same
## structural test .buildMatingUnitForest()'s Decision-2 spouse
## duplication applies at mint time) contributes NO term-4 row. Measured
## S683 on the real 375 fixture: the pull dragged marry-in triples toward
## the mate's distant real occurrence (the owner-flagged ~950/1190 px
## P49ZD1 drop jogs) and CAUSED the census's one class-(d)
## dup-adjacent-to-real case rather than preventing it -- jogs 165 -> 95,
## c2 105 -> 29, d 1 -> 0, b unchanged, the 5 packing fixtures
## byte-identical. kinship2 has no duplicate-proximity term at all (S670
## report Sec. 3); the curved connector, not proximity, links a spouse
## duplicate to its real occurrence.
##
## NOTE on the small-fixture choice below: Track C and the un-widened
## polygamy shape are constraint-saturated -- their solved rows sit fully
## on the minSep floors, so wDup measurably moves NOTHING there even at
## the pre-S683 engine (probed directly, max |delta| ~1e-8). The two
## fixtures below are built with row slack so the term's presence or
## absence is actually observable.

## Marry-in fixture whose ONLY duplicate is a spouse (B2) duplicate: M has
## her own parent edge (G1 x G2), marries A (own parents A1 x A2), child
## C. A anchors (same gen, 1 unit each, "A" < "M" radix), so M's
## occurrence at the A x M unit renders as __dup_M_1 while her real node
## renders under G1/G2.
.qpSpouseDupMarryIn <- function() {
  ped <- data.frame(
    id   = c("G1", "G2", "M", "A1", "A2", "A", "C"),
    sire = c(NA, NA, "G1", NA, NA, "A1", "A"),
    dam  = c(NA, NA, "G2", NA, NA, "A2", "M"),
    sex  = c("M", "F", "F", "M", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

test_that(".solveJointQP()'s duplicate-proximity term is INERT for a
           spouse (B2) duplicate -- wDup = 1 and wDup = 0 solve to
           identical positions on a marry-in fixture whose only
           duplicate is B2-shaped (S683: term 4 skips spouse
           duplicates; at the pre-S683 engine the two solves differed
           by up to 0.64 raw units on this fixture, the drag mechanism
           in miniature)", {
  built <- .qpProvisional(.qpSpouseDupMarryIn)
  dups <- built$forest$duplicates
  ## Fixture-shape guard: exactly one duplicate, the B2-shaped M.
  expect_equal(dups$id, "__dup_M_1")
  expect_equal(dups$realId, "M")

  s1 <- .solveJointQP(built$provisionalPos, built$forest$matingUnits,
                      dups, built$forest$childEdges, wDup = 1.0)
  s0 <- .solveJointQP(built$provisionalPos, built$forest$matingUnits,
                      dups, built$forest$childEdges, wDup = 0.0)
  expect_equal(s1$x[match(s0$id, s1$id)], s0$x, tolerance = 1e-7)
})

## Polygamy fixture whose ONLY duplicate is a B1 duplicate, with enough
## row slack (two 3-child sibships widening gen 2) for the term to be
## observable: founder F (no parent edge, never a single parent -- both
## children of each union carry both parents) mates W1 and W2, each of
## whom has her own parents and anchors her unit (deeper gen). F's first
## non-anchor occurrence is free; the second mints __dup_F_1.
.qpPolygamyWideB1 <- function() {
  ped <- data.frame(
    id   = c("F", "D1a", "D1b", "D2a", "D2b", "W1", "W2",
             "K1a", "K1b", "K1c", "K2a", "K2b", "K2c"),
    sire = c(NA, NA, NA, NA, NA, "D1a", "D2a",
             "F", "F", "F", "F", "F", "F"),
    dam  = c(NA, NA, NA, NA, NA, "D1b", "D2b",
             "W1", "W1", "W1", "W2", "W2", "W2"),
    sex  = c("M", "M", "F", "M", "F", "F", "F",
             "M", "F", "M", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  ped
}

test_that(".solveJointQP()'s duplicate-proximity term stays ACTIVE for a
           polygamy (B1) duplicate -- wDup = 1 vs wDup = 0 move
           __dup_F_1 by more than 0.1 raw units on a slack-row polygamy
           fixture (guards the S683 exclusion's boundary: the skip must
           not widen to B1 duplicates, whose pull keeps one
           individual's occurrences near each other; this pin holds at
           the pre-S683 engine too, by design -- a boundary guard, not
           a failing-RED case)", {
  built <- .qpProvisional(.qpPolygamyWideB1)
  dups <- built$forest$duplicates
  ## Fixture-shape guard: exactly one duplicate, the B1-shaped F.
  expect_equal(dups$id, "__dup_F_1")
  expect_equal(dups$realId, "F")

  s1 <- .solveJointQP(built$provisionalPos, built$forest$matingUnits,
                      dups, built$forest$childEdges, wDup = 1.0)
  s0 <- .solveJointQP(built$provisionalPos, built$forest$matingUnits,
                      dups, built$forest$childEdges, wDup = 0.0)
  d1 <- s1$x[s1$id == "__dup_F_1"]
  d0 <- s0$x[s0$id == "__dup_F_1"]
  expect_gt(abs(d1 - d0), 0.1)
})
