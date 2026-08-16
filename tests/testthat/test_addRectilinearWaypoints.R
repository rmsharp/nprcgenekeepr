## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .addRectilinearWaypoints() -- Pedigree Diagram Option 2, issue
## #142 rectilinear mate-line/sibship-bar waypoint style
## (docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md
## D1/D2/D5). A pure post-processing step: consumes the already-final
## node/edge tables makePedigreeMatingLayout() assembles (direct style) plus
## .buildMatingUnitForest()'s structural output and .positionMatingUnitForest()'s
## coordinates, and returns a NEW node/edge pair with invisible waypoint
## nodes inserted so mate-line and sibship-bar edges route as a strict
## right angle instead of a direct diagonal/straight segment. No change to
## .buildMatingUnitForest()/.positionMatingUnitForest() or to
## makePedigreeMatingLayout()'s own default ("direct") behavior -- this is
## Slice 1 of the issue #142 implementation: the internal helper only, not
## yet wired to any edgeStyle parameter or UI control (a later slice).
##
## Session 465's Pre-RED live-verification (docs/planning/
## pedigree-diagram-rectilinear-waypoint-design-plan.md §11 addendum) found
## the design's originally-specified hidden = TRUE mechanism does not work
## -- vis.js suppresses every edge connected to a hidden node, regardless of
## the edge's own hidden setting. The corrected mechanism verified there:
## waypoint nodes get size = 0 and fully transparent color (not
## hidden = TRUE), and every new waypoint-touching edge gets an explicit,
## non-inherited color (vis.js edges otherwise default to inheriting color
## from their 'from' node's border, which silently breaks any edge whose
## 'from' side is the transparent waypoint node).

## ---- test helpers (not exported, local to this file) --------------------

.buildLayoutAndForest <- function(ped) {
  ## Track 2 (docs/planning/pedigree-diagram-kinship2-fidelity-remediation-
  ## plan.md) flips makePedigreeMatingLayout()'s own default to
  ## "rectilinear" -- this helper must still build DIRECT-style
  ## preconditions explicitly, since .addRectilinearWaypoints() (the
  ## function under test throughout this file) is the thing that ADDS the
  ## waypoints; it expects direct-style input, not already-rectilinear
  ## input.
  layout <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  list(nodes = layout$nodes, edges = layout$edges, forest = forest, pos = pos)
}

.isWaypoint <- function(ids) {
  grepl("^__drop_|^__bar_|^__proj_", ids)
}

## ---- input validation -----------------------------------------------

.validationPed <- data.frame(
  id = c("P1", "P2", "C1"),
  sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
  sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
  stringsAsFactors = FALSE
)

test_that(".addRectilinearWaypoints rejects non-data-frame 'nodes'/'edges'", {
  inputs <- .buildLayoutAndForest(.validationPed)
  expect_error(
    .addRectilinearWaypoints(list(a = 1), inputs$edges, inputs$forest,
                              inputs$pos),
    "data frame"
  )
  expect_error(
    .addRectilinearWaypoints(inputs$nodes, list(a = 1), inputs$forest,
                              inputs$pos),
    "data frame"
  )
})

test_that(".addRectilinearWaypoints rejects a non-data-frame 'pos'", {
  inputs <- .buildLayoutAndForest(.validationPed)
  expect_error(
    .addRectilinearWaypoints(inputs$nodes, inputs$edges, inputs$forest,
                              list(a = 1)),
    "data frame"
  )
})

test_that(".addRectilinearWaypoints rejects a 'forest' missing required
           components", {
  inputs <- .buildLayoutAndForest(.validationPed)
  expect_error(
    .addRectilinearWaypoints(inputs$nodes, inputs$edges, list(a = 1),
                              inputs$pos),
    "matingUnits|childEdges"
  )
})

## ---- D1: 1-child mating unit (degenerate 2-point chain, no special case) -

test_that(".addRectilinearWaypoints inserts a 2-point sibship-bar chain (one
           drop node, one bar-point node) for a 1-child mating unit, and
           drops the original direct union -> child edge", {
  ped <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  unitId <- inputs$forest$matingUnits$id
  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  wpIds <- result$nodes$id[.isWaypoint(result$nodes$id)]
  expect_equal(length(wpIds), 2L)  # k + 1 = 2 (drop + 1 bar-point)
  dropId <- wpIds[grepl("^__drop_", wpIds)]
  barId <- wpIds[grepl("^__bar_", wpIds)]
  expect_equal(length(dropId), 1L)
  expect_equal(length(barId), 1L)

  ## Every new waypoint node is invisible: size 0, fully transparent.
  wpRows <- result$nodes[result$nodes$id %in% wpIds, ]
  expect_true(all(wpRows$size == 0))
  expect_true(all(wpRows$`color.background` == "rgba(0,0,0,0)"))
  expect_true(all(wpRows$`color.border` == "rgba(0,0,0,0)"))

  ## Drop node sits at the union's own x. Track 1 (issue #160, found S591,
  ## plan docs/planning/pedigree-diagram-same-row-collision-avoidance-
  ## plan.md section 2.1): the bar/drop row is a genuine intermediate row
  ## (sibshipBarFraction = 0.4 of the way from the union's own row to the
  ## child's row) -- NOT the child's own row, which is the direct
  ## mechanical cause of issue #160's 2 reported collisions.
  unitRow <- result$nodes[result$nodes$id == unitId, ]
  c1Row <- result$nodes[result$nodes$id == "C1", ]
  dropRow <- result$nodes[result$nodes$id == dropId, ]
  barRow <- result$nodes[result$nodes$id == barId, ]
  expectedBarY <- c1Row$y - (c1Row$y - unitRow$y) * 0.4
  expect_equal(dropRow$x, unitRow$x)
  expect_equal(dropRow$y, expectedBarY)
  expect_equal(barRow$x, c1Row$x)
  expect_equal(barRow$y, expectedBarY)
  expect_true(expectedBarY > unitRow$y && expectedBarY < c1Row$y)
  expect_false(isTRUE(expectedBarY == c1Row$y))

  ## New edges: union -- drop (vertical), drop -- bar (the 1-segment
  ## chain, horizontal or zero-length per D1 step 4), bar -- C1
  ## (vertical) -- 2k + 1 = 3 total.
  newEdges <- result$edges[result$edges$from %in% c(unitId, wpIds) |
                             result$edges$to %in% c(unitId, wpIds), ]
  newEdges <- newEdges[.isWaypoint(newEdges$from) |
                          .isWaypoint(newEdges$to), ]
  expect_equal(nrow(newEdges), 3L)
  expect_true(any(newEdges$from == unitId & newEdges$to == dropId))
  expect_true(any((newEdges$from == dropId & newEdges$to == barId) |
                    (newEdges$from == barId & newEdges$to == dropId)))
  expect_true(any(newEdges$from == barId & newEdges$to == "C1"))

  ## New waypoint edges carry an explicit, non-inherited color -- not
  ## relying on vis.js's default color.inherit = "from" (which would
  ## silently render invisible when the 'from' side is the transparent
  ## waypoint node -- Session 465's Pre-RED finding, design doc §11).
  expect_false(any(is.na(newEdges$color)))

  ## The original direct union -> C1 edge is gone.
  expect_false(any(result$edges$from == unitId & result$edges$to == "C1"))
})

## ---- D1: 3-child sibship (general chain, sort order is data-driven, not
## hardcoded to a specific left/middle/right assumption) -------------------

test_that(".addRectilinearWaypoints inserts a 4-point sibship-bar chain for
           a 3-child sibship, with the drop/bar points connected in
           strictly ascending x order regardless of where the drop point
           falls relative to the 3 children", {
  ped <- data.frame(
    id = c("P1", "P2", "C1", "C2", "C3"),
    sire = c(NA, NA, "P1", "P1", "P1"), dam = c(NA, NA, "P2", "P2", "P2"),
    sex = c("M", "F", "M", "F", "M"), gen = c(0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  unitId <- inputs$forest$matingUnits$id
  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  wpIds <- result$nodes$id[.isWaypoint(result$nodes$id)]
  expect_equal(length(wpIds), 4L)  # k + 1 = 4 (1 drop + 3 bar-points)
  dropId <- wpIds[grepl("^__drop_", wpIds)]
  barIds <- wpIds[grepl("^__bar_", wpIds)]
  expect_equal(length(barIds), 3L)

  ## Each bar-point sits at its own child's x. Track 1 (issue #160, plan
  ## section 2.1): the bar row is a genuine intermediate row (0.4 of the
  ## way from the union's own row to the child row), never the child's own
  ## row.
  unitRow <- result$nodes[result$nodes$id == unitId, ]
  childRows <- result$nodes[result$nodes$id %in% c("C1", "C2", "C3"), ]
  for (bid in barIds) {
    childId <- sub("^__bar_", "", bid)
    barRow <- result$nodes[result$nodes$id == bid, ]
    childRow <- childRows[childRows$id == childId, ]
    expectedBarY <- childRow$y - (childRow$y - unitRow$y) * 0.4
    expect_equal(barRow$x, childRow$x)
    expect_equal(barRow$y, expectedBarY)
    expect_true(expectedBarY > unitRow$y && expectedBarY < childRow$y)
    expect_false(isTRUE(expectedBarY == childRow$y))
  }

  ## The bar chain connects all 4 points (drop + 3 bar-points) in
  ## strictly ascending x order -- derived from the ACTUAL x values, not
  ## an assumed left/middle/right position for the drop point.
  barPoints <- result$nodes[result$nodes$id %in% c(dropId, barIds), ]
  ord <- order(barPoints$x)
  sortedIds <- barPoints$id[ord]
  chainEdges <- result$edges[
    (result$edges$from %in% c(dropId, barIds)) &
      (result$edges$to %in% c(dropId, barIds)), ]
  expect_equal(nrow(chainEdges), 3L)  # k = 3 chain segments
  for (i in seq_len(length(sortedIds) - 1L)) {
    a <- sortedIds[i]; b <- sortedIds[i + 1L]
    expect_true(any((chainEdges$from == a & chainEdges$to == b) |
                      (chainEdges$from == b & chainEdges$to == a)),
                info = sprintf("expected a chain segment between %s and %s",
                               a, b))
  }

  ## Total new nodes/edges match the design's own k+1 / 2k+1 formula.
  expect_equal(length(wpIds), 4L)
  totalNewEdges <- sum(.isWaypoint(result$edges$from) |
                          .isWaypoint(result$edges$to))
  expect_equal(totalNewEdges, 7L)  # 2*3 + 1

  ## The 3 original direct union -> child edges are gone.
  for (cid in c("C1", "C2", "C3")) {
    expect_false(any(result$edges$from == unitId & result$edges$to == cid))
  }
})

## ---- D1: issue #160 collision 1's exact mechanism -- a sibship child who
## anchors her own mating union (Track 1, docs/planning/pedigree-diagram-
## same-row-collision-avoidance-plan.md section 2.1, found S591/S592) ------
## Issue #160 collision 1: 204/205 are children of 201x202 (a sibship bar).
## 204 separately anchors her own union with 203; by Track 4's ratified
## invariant (matingUnits$gen == genOf[[anchor]]), that union's gen equals
## 204's own gen -- the SAME row 201x202's sibship-bar children (204/205)
## occupy, and (pre-fix) the SAME row the OLD bar-waypoint y formula
## (y = childY) stamped every bar/drop point at. This fixture reproduces
## that structural mechanism (C1 anchors her own union with M1): before
## Track 1, the union's own y and the sibship bar's y are identical; the
## fix's whole point is to make that impossible regardless of x-placement.

test_that(".addRectilinearWaypoints's D1 bar row never coincides with a
           same-generation union's own row -- issue #160 collision 1's
           exact mechanism (a sibship child anchors her own mating
           union)", {
  ped <- data.frame(
    id   = c("P1", "P2", "C1", "C2", "M1", "GC1"),
    sire = c(NA, NA, "P1", "P1", NA, "M1"),
    dam  = c(NA, NA, "P2", "P2", NA, "C1"),
    sex  = c("M", "F", "F", "M", "M", "F"),
    gen  = c(0L, 0L, 1L, 1L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  matingUnits <- inputs$forest$matingUnits
  unit1 <- matingUnits$id[matingUnits$sire == "P1" & matingUnits$dam == "P2"]
  unit2 <- matingUnits$id[matingUnits$sire == "M1" & matingUnits$dam == "C1"]
  expect_equal(length(unit1), 1L)
  expect_equal(length(unit2), 1L)

  ## Track 4's own ratified invariant puts unit2 at gen 1 regardless of
  ## which parent (C1 or M1) wins the anchor tie-break, since both are gen
  ## 1 -- the same row P1xP2's own children (C1/C2, also gen 1) occupy.
  expect_equal(matingUnits$gen[matingUnits$id == unit2], 1L)

  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  unit1Row <- result$nodes[result$nodes$id == unit1, ]
  unit2Row <- result$nodes[result$nodes$id == unit2, ]
  dropId1 <- sprintf("__drop_%s", unit1)
  barIds1 <- sprintf("__bar_%s", c("C1", "C2"))
  bar1Rows <- result$nodes[result$nodes$id %in% c(dropId1, barIds1), ]
  expect_equal(nrow(bar1Rows), 3L)

  ## The guarantee under test: unit1's D1 bar/drop row is never unit2's
  ## own row (or any other pinned node's row), and sits strictly between
  ## unit1's own row and the children's row -- never stamped at childY.
  c1Row <- result$nodes[result$nodes$id == "C1", ]
  expect_false(any(bar1Rows$y == unit2Row$y))
  expect_false(any(bar1Rows$y == c1Row$y))
  expect_true(all(bar1Rows$y > unit1Row$y & bar1Rows$y < c1Row$y))

  ## Track 1 never moves an existing (non-waypoint) node's VALUE -- only a
  ## synthetic waypoint's y changes. expect_equal, not expect_identical: a
  ## barY arithmetic result is a double, and rbind() widens the whole
  ## shared y column to double even for untouched integer values -- a
  ## harmless R storage-type promotion, not a value change.
  origNonWp <- inputs$nodes[order(inputs$nodes$id), c("id", "x", "y")]
  rownames(origNonWp) <- NULL
  resultNonWp <- result$nodes[!.isWaypoint(result$nodes$id), ]
  resultNonWp <- resultNonWp[order(resultNonWp$id), c("id", "x", "y")]
  rownames(resultNonWp) <- NULL
  expect_equal(origNonWp, resultNonWp)
})

## ---- D1 generalizes to a D5 single-known-parent group (no mate-line) ----

test_that(".addRectilinearWaypoints builds a sibship-bar chain for a D5
           single-known-parent group (from = a real parent id, not a
           union), with no mate-line waypoint touching it (no mating unit
           exists for this parent)", {
  ped <- data.frame(
    id = c("P", "C1", "C2"),
    sire = c(NA, "P", "P"), dam = c(NA, NA, NA),
    sex = c("M", "F", "M"), gen = c(0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  expect_equal(nrow(inputs$forest$matingUnits), 0L)  # no 2-parent unit at all
  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  wpIds <- result$nodes$id[.isWaypoint(result$nodes$id)]
  expect_equal(length(wpIds), 3L)  # k + 1 = 3 (1 drop + 2 bar-points)
  dropId <- wpIds[grepl("^__drop_", wpIds)]
  expect_true(any(result$edges$from == "P" & result$edges$to == dropId))
  expect_false(any(result$edges$from == "P" & result$edges$to == "C1"))
  expect_false(any(result$edges$from == "P" & result$edges$to == "C2"))
})

## ---- D2: both parents at the same gen -- zero projection nodes ---------

test_that(".addRectilinearWaypoints adds zero projection nodes for a
           mating unit whose anchor and non-anchor parents are already at
           the same gen (D2's no-op case), and leaves the existing
           mate-line edges unchanged", {
  ped <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  unitId <- inputs$forest$matingUnits$id
  mateEdgesBefore <- inputs$edges[inputs$edges$to == unitId, ]
  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  projIds <- result$nodes$id[grepl("^__proj_", result$nodes$id)]
  expect_equal(length(projIds), 0L)

  mateEdgesAfter <- result$edges[result$edges$to == unitId, ]
  expect_setequal(mateEdgesBefore$from, mateEdgesAfter$from)
})

## ---- D2: a dangling parent ELSEWHERE in the pedigree must not spuriously
## dogleg an unrelated, already-on-row union (found S555, incidental to the
## consanguineous-marker PRE-RED investigation; BACKLOG.md Housekeeping) --
## .positionMatingUnitForest()'s dangling-parent gen fallback
## (R/makePedigreeDiagramData.R ~line 646) used vapply(..., numeric(1L)),
## widening the WHOLE 'genOf' vector from integer to double via c()'s type-
## promotion rule the moment ANY dangling parent exists anywhere in 'ped' --
## not just the dangling entries. .addRectilinearWaypoints()'s D2 loop
## compares gens via identical(), which is type-sensitive
## (identical(0, 0L) is FALSE), so this fixture's P1xC1 union -- the same
## "both parents at the same gen" no-op case as the precedent test above --
## started spuriously doglegging purely because an UNRELATED second union
## (OTHERxDANGLING_MOM) referenced a dangling parent. Empirically confirmed
## against unmodified source (3 spurious __proj_ nodes) before writing this
## assertion. --------------------------------------------------------------

test_that(".addRectilinearWaypoints adds zero projection nodes for a
           mating unit whose parents are at the same gen (D2's no-op case)
           even when an UNRELATED mating unit elsewhere in the same
           pedigree has a dangling parent", {
  ped <- data.frame(
    id = c("P1", "P2", "C1", "OTHER", "OTHERCHILD"),
    sire = c(NA, NA, "P1", NA, "OTHER"),
    dam = c(NA, NA, "P2", NA, "DANGLING_MOM"),
    sex = c("M", "F", "M", "M", "F"),
    gen = c(0L, 0L, 1L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  unitId <- inputs$forest$matingUnits$id[inputs$forest$matingUnits$sire ==
                                            "P1"]
  mateEdgesBefore <- inputs$edges[inputs$edges$to == unitId, ]
  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  projIds <- result$nodes$id[grepl("^__proj_", result$nodes$id)]
  expect_equal(length(projIds), 0L)

  mateEdgesAfter <- result$edges[result$edges$to == unitId, ]
  expect_setequal(mateEdgesBefore$from, mateEdgesAfter$from)
})

## ---- D2: non-anchor parent off-row -- RESOLVED by issue #143's fix ------
## Before issue #143's fix, this was "the common 96/237 real case": DAM (a
## free-pass, non-anchor parent) rendered at her own gen (0) instead of her
## mating unit's gen (1), triggering this dogleg. Issue #143's fix moves
## DAM's displayed row to her mating unit's own gen, so she is now ON-ROW
## for this exact fixture -- the dogleg no longer fires. Confirmed
## empirically this session (docs/planning/
## issue143-founder-positioning-fix-plan.md §4.3's own prediction). No
## non-anchor-off-row scenario survives on any real fixture post-fix (the
## dedicated regression test in test_positionMatingUnitForest.R asserts
## zero remaining non-anchor mismatches) -- this test now documents the
## "already on-row" no-op case instead, mirroring the "D2: both parents at
## the same gen" test above.

test_that(".addRectilinearWaypoints adds zero projection nodes for a
           mating unit whose non-anchor parent USED TO be off-row before
           issue #143's fix, and is now on-row (matching its mating
           unit's own gen), leaving the anchor's own direct edge
           unchanged", {
  ped <- data.frame(
    id = c("GRANDSIRE", "SIRE", "DAM", "CHILD"),
    sire = c(NA, "GRANDSIRE", NA, "SIRE"),
    dam = c(NA, NA, NA, "DAM"),
    sex = c("M", "M", "F", "M"),
    gen = c(0L, 1L, 0L, 2L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  unitId <- inputs$forest$matingUnits$id
  expect_equal(inputs$forest$matingUnits$anchor, "SIRE")  # non-founder anchors
  expect_equal(inputs$forest$matingUnits$gen, 1L)         # max(SIRE=1, DAM=0)

  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  projIds <- result$nodes$id[grepl("^__proj_", result$nodes$id)]
  expect_equal(length(projIds), 0L)

  ## DAM's direct edge to the unit is untouched -- no dogleg needed, she
  ## renders on-row (gen 1, her unit's own gen) post-fix.
  expect_true(any(result$edges$from == "DAM" & result$edges$to == unitId))
  expect_equal(inputs$pos$gen[inputs$pos$id == "DAM"], 1L)

  ## The anchor's (SIRE's) own direct edge remains untouched too.
  expect_true(any(result$edges$from == "SIRE" & result$edges$to == unitId))
})

## ---- D2: anchor parent off-row -- RESOLVED by issue #144's fix, then
## by Track 4's structural invariant -----------------------------------
## Before issue #144's fix, this was the anchor-side counterpart to the
## "D2: non-anchor parent off-row" test above: SIRE (the anchor of unit1)
## rendered at his own raw gen (1) instead of his mating unit's gen (2),
## triggering an anchor-side dogleg. Issue #144's fix (docs/planning/
## issue144-anchor-row-mismatch-fix-plan.md, Candidate B: effGenOf) moved
## SIRE's displayed row to match his unit instead, resolving that
## particular case without eliminating the defect class.
##
## Track 4 (Candidate A, gen-aware D2, this session): CHANGED again, and
## more fundamentally this time -- gen-first D2 selection now picks DAM
## (gen 2), not SIRE (gen 1), as unit1's anchor (she beats him on gen
## alone, overriding the old founder-tie/mate-count tie-break that used to
## favor SIRE). DAM's own raw gen already equals unit1's gen by
## construction (Track 4 §2.3's structural invariant), so she needs no
## relocation and never did; she also anchors her OTHER unit (with
## OTHERMATE) the same way, so she is never duplicated at all -- this
## fixture now has 0 duplicates, not 1. SIRE becomes the free-pass
## non-anchor occurrence at unit1, still displayed at unit1's gen (2) via
## issue #143's unchanged non-anchor override, unaffected by Track 4. Full
## rewrite, not a value tweak -- both fixtures' anchor identity changes.

test_that(".addRectilinearWaypoints adds zero projection nodes for a
           mating unit whose anchor (Track 4: gen-first D2 selects DAM,
           not SIRE) already has genOf[[anchor]] == unit gen by
           construction -- leaves both the anchor's own direct edge and
           the non-anchor's free-pass edge unchanged", {
  ped <- data.frame(
    id = c("SGF", "SGM", "SIRE", "DGP", "DAM", "OTHERMATE", "CHILD",
           "OTHERCHILD"),
    sire = c(NA, NA, "SGF", NA, "DGP", NA, "SIRE", "OTHERMATE"),
    dam = c(NA, NA, "SGM", NA, NA, NA, "DAM", "DAM"),
    sex = c("M", "F", "M", "M", "F", "M", "M", "F"),
    gen = c(0L, 0L, 1L, 0L, 2L, 0L, 3L, 3L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  forest <- inputs$forest
  unit1 <- forest$matingUnits$id[forest$matingUnits$sire == "SIRE" &
                                    forest$matingUnits$dam == "DAM"]
  expect_equal(length(unit1), 1L)
  expect_equal(forest$matingUnits$anchor[forest$matingUnits$id == unit1],
               "DAM")  # deeper gen (2) beats SIRE's (1)
  expect_equal(forest$matingUnits$gen[forest$matingUnits$id == unit1], 2L)
  ## DAM anchors BOTH her units now (this one and OTHERMATE's) -- neither
  ## ever needs a duplicate, since her own raw gen already equals both
  ## units' gens by construction.
  expect_equal(nrow(forest$duplicates), 0L)

  ## DAM (anchor) is on-row by construction -- no relocation mechanism
  ## exists any longer, and none is needed.
  expect_equal(inputs$pos$gen[inputs$pos$id == "DAM"], 2L)
  ## SIRE is the free-pass non-anchor occurrence, on-row via issue #143's
  ## still-unchanged override (his own raw gen is 1).
  expect_equal(inputs$pos$gen[inputs$pos$id == "SIRE"], 2L)

  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      forest, inputs$pos)

  ## This test scopes its assertions to unit1 specifically, not a global
  ## proj count -- other units in this fixture are out of scope here.
  projIds <- result$nodes$id[grepl(sprintf("^__proj_.*_%s$", unit1),
                                    result$nodes$id)]
  expect_equal(length(projIds), 0L)

  ## Both original direct/free-pass edges into unit1 are untouched -- no
  ## dogleg needed on either side.
  expect_true(any(result$edges$from == "DAM" & result$edges$to == unit1))
  expect_true(any(result$edges$from == "SIRE" & result$edges$to == unit1))
})

## ---- real 375-individual bundled fixture: node-count re-measurement ----
## (design doc §7/§9/§8: "a hard gate, not a nice-to-have" before deciding
## the rectilinear-mode individual cap -- re-confirm the actual generated
## count now that the code exists, rather than trusting the analytical
## 1,375 estimate.)

test_that(".addRectilinearWaypoints applied to the full real
           375-individual bundled fixture produces the node count Track 4
           predicts (714 direct-style nodes + 488 D1 waypoints +
           0 D2 projections = 1,202 -- CHANGED from 1,228/1,279/1,375:
           Track 4's gen-first D2 selection drops the direct-style node
           count from 740 to 714 [fewer duplicates, test_buildMatingUnitForest.R's
           own updated figure], while D2 projections stay at 0, now as a
           structural invariant rather than an empirical outcome, since
           #143 resolved all 96 non-anchor D2 mismatches and Track 4 now
           makes anchor-side mismatches impossible by construction), or
           documents the actual count if it drifts", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  expect_equal(nrow(inputs$nodes), 714L)  # CHANGED from 740L, Track 4

  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)
  expect_equal(nrow(result$nodes), 1202L)  # CHANGED from 1228L, Track 4

  ## No NA coordinates or duplicate (id, waypoint) collisions among the
  ## new waypoint nodes.
  wpRows <- result$nodes[.isWaypoint(result$nodes$id), ]
  expect_false(any(is.na(wpRows$x)))
  expect_false(any(is.na(wpRows$y)))
  expect_false(any(duplicated(wpRows$id)))
})

## ---- Track 1 (issue #160): D1 bar/drop row never coincides with any
## pinned (real/duplicate/union) node's row for the common 1-generation-gap
## case, on the real 375-individual fixture -- the closest available
## exhaustive check for the actual collision risk (488 D1 waypoints across
## many sibships/generation gaps). A stronger claim, "barY is never an
## exact multiple of yScale for ANY gap", is not literally true: for a
## fixed rational sibshipBarFraction = p/q in lowest terms (0.4 = 2/5), a
## generation gap that is an exact multiple of q (5) reproduces the
## coincidence -- no fixed fraction is collision-free for every possible
## gap. Found empirically on this fixture (owner-directed, found S593,
## disclosed rather than hidden by a weaker assertion): exactly 2
## waypoints, one gap-5 D1 group (a union whose child is placed 5
## generations below it). Deferred to Track 2's general same-row
## detect-and-jog framework (plan section 2.2), which is not gap-specific
## and is the designed backstop for whatever Track 1 cannot structurally
## eliminate -- counted here, not silently dropped, so a regression (a
## growing residual) would be caught. --------------------------------------

test_that(".addRectilinearWaypoints's D1 bar/drop waypoints never share a
           row with any real/duplicate/union node for a 1-generation gap
           (the common case, and issue #160's own reported shape), on the
           real 375-individual bundled fixture; a rare, disclosed residual
           of exactly 2 waypoints survives for one larger-gap group; and no
           existing node's x/y ever changes", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  wpRows <- result$nodes[.isWaypoint(result$nodes$id), ]
  barWpRows <- wpRows[grepl("^__(drop|bar)_", wpRows$id), ]
  expect_true(nrow(barWpRows) > 0L)

  pinnedYs <- unique(result$nodes$y[!.isWaypoint(result$nodes$id)])

  ## Per-D1-group collision tally, by that group's own generation gap
  ## (childGen - parentGen), mirroring the production D1 loop's own
  ## per-fromId grouping.
  childEdges <- inputs$forest$childEdges
  genOf <- stats::setNames(inputs$pos$gen, inputs$pos$id)
  gap1Collisions <- 0L
  totalResidual <- 0L
  for (fromId in unique(childEdges$from)) {
    kids <- childEdges$to[childEdges$from == fromId]
    gap <- unname(genOf[kids[1L]] - genOf[fromId])
    groupIds <- c(sprintf("__drop_%s", fromId), sprintf("__bar_%s", kids))
    groupRows <- result$nodes[result$nodes$id %in% groupIds, ]
    hits <- sum(groupRows$y %in% pinnedYs)
    if (!is.na(gap) && gap == 1L) {
      gap1Collisions <- gap1Collisions + hits
    }
    totalResidual <- totalResidual + hits
  }
  expect_equal(gap1Collisions, 0L)
  expect_equal(totalResidual, 2L)

  ## Track 1 never moves an existing (non-waypoint) node's VALUE -- only a
  ## synthetic waypoint's y changes. expect_equal, not expect_identical: a
  ## barY arithmetic result is a double, and rbind() widens the whole
  ## shared y column to double even for untouched integer values -- a
  ## harmless R storage-type promotion, not a value change.
  origNonWp <- inputs$nodes[order(inputs$nodes$id), c("id", "x", "y")]
  rownames(origNonWp) <- NULL
  resultNonWp <- result$nodes[!.isWaypoint(result$nodes$id), ]
  resultNonWp <- resultNonWp[order(resultNonWp$id), c("id", "x", "y")]
  rownames(resultNonWp) <- NULL
  expect_equal(origNonWp, resultNonWp)
})

## ---- Track 1 (issue #160), gotcha flagged in the collision-avoidance
## plan's own section 8 (found S592, verified S593): applying the SAME
## sibshipBarFraction to every sibship means two DIFFERENT sibships
## spanning the same generation gap can still land their bars on the
## identical row if their x-ranges overlap -- a bar-vs-bar collision, not
## the bar-vs-pinned-node case the tests above cover. Track 1
## substantially reduces this (the offset depends on BOTH the parent's and
## the child's own row, not just the child's, so most same-generation
## sibships now land on different rows) but does not eliminate it --
## disclosed and counted here, not silently dropped, deferred to Track 2's
## general framework alongside the other residual above.
##
## Track 3 update (docs/planning/pedigree-diagram-same-row-collision-
## avoidance-plan.md sec2.3/sec6 Session C, REFACTOR, this session):
## x-spans are NO LONGER unaffected by union clamping -- each group's
## "drop" point sits at its OWN UNION's x (barPointX <- c(xOf[[fromId]],
## xOf[kids]), fromId being the union id), and Track 3 pulls a runaway
## union back inside its own parents' span. That is exactly Track 3's
## purpose (fixing the S583 parent-span containment defect), but it
## moves the drop point back INTO the x-region other relatives'
## subtrees occupy, substantially WORSENING this already-disclosed
## bar-vs-bar residual: 42 -> 348 pre-Track-1-equivalent baseline hits,
## 9 -> 116 post-Track-1 hits (both re-measured live this session).
## Owner-directed (AskUserQuestion, this session): accept as a disclosed
## trade-off -- Track 3 fixes a DIFFERENT, higher-priority invariant
## (parent-span containment, kinship2 parity) than this ALREADY-
## ACKNOWLEDGED-as-imperfect residual (sec8's own "not examined in this
## plan" framing) -- not fixed here; filed as its own BACKLOG.md
## follow-up per sec8's own instruction ("file it as its own issue if
## found").

test_that(".addRectilinearWaypoints's D1 bar-vs-bar same-row x-overlap
           collisions (2 different sibships sharing a generation gap,
           whose bar x-spans overlap) are substantially reduced by Track
           1 relative to pre-Track-1, but WORSENED by Track 3's parent-
           span clamp (an accepted, disclosed trade-off -- see the
           docstring above), on the real 375-individual bundled fixture
           -- a residual named in the collision-avoidance plan's own
           section 8, counted here so a further regression would be
           caught", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  childEdges <- inputs$forest$childEdges
  xOf <- stats::setNames(result$nodes$x, result$nodes$id)
  yOf <- stats::setNames(result$nodes$y, result$nodes$id)
  genOf <- stats::setNames(inputs$pos$gen, inputs$pos$id)
  fromIds <- unique(childEdges$from)

  groups <- lapply(fromIds, function(fromId) {
    kids <- childEdges$to[childEdges$from == fromId]
    ids <- c(sprintf("__drop_%s", fromId), sprintf("__bar_%s", kids))
    ids <- ids[ids %in% names(xOf)]
    list(y = unname(yOf[ids[1L]]), xlo = min(xOf[ids]), xhi = max(xOf[ids]))
  })
  n <- length(groups)
  countHits <- function(ys) {
    hits <- 0L
    for (i in seq_len(n - 1L)) {
      for (j in seq(i + 1L, n)) {
        overlap <- groups[[i]]$xlo <= groups[[j]]$xhi &&
          groups[[j]]$xlo <= groups[[i]]$xhi
        if (isTRUE(all.equal(ys[[i]], ys[[j]])) && overlap) {
          hits <- hits + 1L
        }
      }
    }
    hits
  }
  newHits <- countHits(vapply(groups, `[[`, numeric(1L), "y"))

  ## OLD-code comparison: every D1 group's bar sat at y = childGen * yScale
  ## (the pre-Track1 formula). x-spans are unaffected by Track 1 (only y
  ## changed) -- but ARE affected by Track 3 (this session), since the
  ## drop point's x is the union's own x, now clamped. Both oldHits and
  ## newHits below are measured against the SAME (post-Track-3) x-spans,
  ## so this remains a clean isolated measurement of Track 1's own y-only
  ## contribution -- re-running the same x-overlap test against the OLD y
  ## assignment measures how much Track 1 actually improved, holding
  ## Track 3's x-span effect constant across both.
  yScale <- 150L
  oldYs <- vapply(fromIds, function(fromId) {
    kids <- childEdges$to[childEdges$from == fromId]
    unname(genOf[kids[1L]]) * yScale
  }, numeric(1L))
  oldHits <- countHits(oldYs)

  ## Track 3 (this session) substantially worsens BOTH counts, since it
  ## moves the drop point's x back toward the union's own (now-clamped)
  ## parents -- an accepted, disclosed trade-off (see the docstring
  ## above), re-measured live this session.
  expect_equal(oldHits, 348L)  # pre-Track1-equivalent baseline, post-Track3
  expect_equal(newHits, 116L)  # post-Track1 AND post-Track3
  expect_true(newHits < oldHits)
})

## ---- issue #154: dangling, free-pass non-anchor parent crash (BACKLOG.md
## former item B3) -- confirmed by direct reproduction against master
## before this fix: the D2 mate-line-dogleg loop built genOf from
## pos$id/pos$gen and looked up every unit's non-anchor side
## unconditionally with genOf[[Nnode]]; a dangling, free-pass parent has no
## row in 'pos' at all (by .positionMatingUnitForest()'s own contract,
## already exercised in test_positionMatingUnitForest.R), so the lookup
## threw "subscript out of bounds". This exact ped already renders fine
## under the default edgeStyle = "direct". ------------------------------

test_that(".addRectilinearWaypoints does not crash when a mating unit's
           non-anchor parent is a dangling, free-pass (non-duplicated)
           reference (issue #154) -- that side simply gets no dogleg
           projection, since there is no rendered node to project", {
  ped <- data.frame(
    id = c("GRANDSIRE", "SIRE", "CHILD"),
    sire = c(NA, "GRANDSIRE", "SIRE"),
    dam = c(NA, NA, "DANGLING_DAM"),
    sex = c("M", "M", "F"),
    gen = c(0L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  result <- expect_error(
    .addRectilinearWaypoints(inputs$nodes, inputs$edges, inputs$forest,
                              inputs$pos),
    NA
  )
  expect_false("DANGLING_DAM" %in% result$nodes$id)
  expect_false(any(is.na(result$nodes$x)))
})

## ---- Issue #133: preserve pre-existing node coloring (not yet wired to
## an edgeStyle at the time of the D1/D2 design; #133's affected-status
## coloring is the first real caller that passes in nodes already carrying
## a color.background/color.border value) ------------------------------

test_that(
  ".addRectilinearWaypoints preserves a pre-existing color.background/
   color.border on passed-in nodes (e.g. issue #133's affected-status
   coloring) rather than resetting every node to NA, while new waypoint
   nodes still get their own fully-transparent override", {
  ped <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  coloredNodes <- inputs$nodes
  coloredNodes$color.background <- ifelse(coloredNodes$id == "P1",
                                           "#CC79A7", NA_character_)
  coloredNodes$color.border <- NA_character_

  result <- .addRectilinearWaypoints(coloredNodes, inputs$edges,
                                      inputs$forest, inputs$pos)

  origRows <- result$nodes[result$nodes$id %in% ped$id, ]
  expect_equal(origRows$color.background[origRows$id == "P1"], "#CC79A7")
  expect_true(is.na(origRows$color.background[origRows$id == "P2"]))
  expect_true(is.na(origRows$color.background[origRows$id == "C1"]))

  wpIds <- result$nodes$id[.isWaypoint(result$nodes$id)]
  wpRows <- result$nodes[result$nodes$id %in% wpIds, ]
  expect_true(nrow(wpRows) > 0L)
  expect_true(all(wpRows$color.background == "rgba(0,0,0,0)"))
  expect_true(all(wpRows$color.border == "rgba(0,0,0,0)"))
})

## ---- Issue #137: preserve pre-existing edge coloring (found S506 -- the
## twin-connector color, D10, was wired into .buildTwinConnectorEdges() but
## silently clobbered here; keptEdges$color was unconditionally reset to NA
## for every kept edge, mirroring the #133 node-color bug this file's own
## test above already guards against, but on the edge side) -----------------

test_that(
  ".addRectilinearWaypoints preserves a pre-existing color on passed-in
   edges (e.g. issue #137's twin-connector coloring) rather than resetting
   every kept edge to NA, while new waypoint edges still get their own
   distinct, non-inherited #2B7CE9", {
  ped <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  ## P1's own mate-line edge (P1 -> the mating unit) survives
  ## .addRectilinearWaypoints() as a kept edge, since both parents share the
  ## unit's own generation here (no D2 dogleg reroute) -- unlike the direct
  ## union -> C1 child edge, which D1's sibship-bar chain always drops.
  coloredEdges <- inputs$edges
  coloredEdges$color <- NA_character_
  coloredEdges$color[coloredEdges$from == "P1"] <- "#009E73"

  result <- .addRectilinearWaypoints(inputs$nodes, coloredEdges,
                                      inputs$forest, inputs$pos)

  origRows <- result$edges[!.isWaypoint(result$edges$from) &
                              !.isWaypoint(result$edges$to), ]
  expect_true(any(origRows$color == "#009E73", na.rm = TRUE))
  expect_true(any(is.na(origRows$color)))

  newEdges <- result$edges[.isWaypoint(result$edges$from) |
                              .isWaypoint(result$edges$to), ]
  expect_true(nrow(newEdges) > 0L)
  expect_true(all(newEdges$color == "#2B7CE9"))
})
