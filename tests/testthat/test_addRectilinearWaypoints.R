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
  layout <- makePedigreeMatingLayout(ped)
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

  ## Drop node sits at the union's own x, on the child's row (y).
  unitRow <- result$nodes[result$nodes$id == unitId, ]
  c1Row <- result$nodes[result$nodes$id == "C1", ]
  dropRow <- result$nodes[result$nodes$id == dropId, ]
  barRow <- result$nodes[result$nodes$id == barId, ]
  expect_equal(dropRow$x, unitRow$x)
  expect_equal(dropRow$y, c1Row$y)
  expect_equal(barRow$x, c1Row$x)
  expect_equal(barRow$y, c1Row$y)

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

  ## Each bar-point sits at its own child's x, on the shared child row.
  childRows <- result$nodes[result$nodes$id %in% c("C1", "C2", "C3"), ]
  for (bid in barIds) {
    childId <- sub("^__bar_", "", bid)
    barRow <- result$nodes[result$nodes$id == bid, ]
    childRow <- childRows[childRows$id == childId, ]
    expect_equal(barRow$x, childRow$x)
    expect_equal(barRow$y, childRow$y)
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

## ---- D2: anchor parent off-row, non-anchor represented by a duplicate --
## (the harder combined case: exercises both the 22% anchor-off-row case
## and the 57/96 non-anchor-is-a-duplicate case simultaneously) ------------

test_that(".addRectilinearWaypoints adds exactly one projection node on the
           ANCHOR side when the anchor (not the non-anchor) is at a
           different gen than the mating unit -- does not assume the
           anchor is always the on-row parent -- and correctly leaves the
           non-anchor's duplicate-node edge unchanged when that side is
           already on-row", {
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
               "SIRE")  # fewer total mating units (1) than DAM (2)
  expect_equal(forest$matingUnits$gen[forest$matingUnits$id == unit1], 2L)
  ## DAM anchors her OTHER unit (with OTHERMATE, a founder), so her
  ## occurrence at unit1 (non-anchor) is a duplicate, not her real node.
  dupRow <- forest$duplicates[forest$duplicates$realId == "DAM" &
                                 forest$duplicates$matingUnitId == unit1, ]
  expect_equal(nrow(dupRow), 1L)
  nonAnchorNodeId <- dupRow$id

  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      forest, inputs$pos)

  ## OTHERMATE (unit2's non-anchor, a founder at gen 0, DAM's own unit2 is
  ## at gen 2) is ALSO off-row -- a second, independent projection is
  ## correctly expected there too. This test scopes its assertions to
  ## unit1's anchor (SIRE) side specifically, not a global proj count.
  projId <- sprintf("__proj_SIRE_%s", unit1)
  expect_true(projId %in% result$nodes$id)
  projRow <- result$nodes[result$nodes$id == projId, ]
  sireRow <- inputs$nodes[inputs$nodes$id == "SIRE", ]
  unitRow <- result$nodes[result$nodes$id == unit1, ]
  expect_equal(projRow$x, sireRow$x)
  expect_equal(projRow$y, unitRow$y)

  expect_true(any(result$edges$from == "SIRE" & result$edges$to == projId))
  expect_true(any(result$edges$from == projId & result$edges$to == unit1))
  expect_false(any(result$edges$from == "SIRE" & result$edges$to == unit1))

  ## DAM's duplicate is already on-row (gen 2 == unit1's gen 2) -- its
  ## original mate-line edge is untouched, not routed through a
  ## projection node.
  expect_true(any(result$edges$from == nonAnchorNodeId &
                     result$edges$to == unit1))
})

## ---- real 375-individual bundled fixture: node-count re-measurement ----
## (design doc §7/§9/§8: "a hard gate, not a nice-to-have" before deciding
## the rectilinear-mode individual cap -- re-confirm the actual generated
## count now that the code exists, rather than trusting the analytical
## 1,375 estimate.)

test_that(".addRectilinearWaypoints applied to the full real
           375-individual bundled fixture produces the node count issue
           #143's fix predicts (740 direct-style nodes + 488 D1 waypoints +
           51 D2 projections = 1,279 -- down from the pre-fix 1,375/147,
           since the fix resolves all 96 non-anchor D2 mismatches, leaving
           only the 51 anchor-side ones issue #144 tracks), or documents
           the actual count if it drifts", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  inputs <- .buildLayoutAndForest(ped)
  expect_equal(nrow(inputs$nodes), 740L)  # direct-style baseline, S459/S461

  result <- .addRectilinearWaypoints(inputs$nodes, inputs$edges,
                                      inputs$forest, inputs$pos)
  expect_equal(nrow(result$nodes), 1279L)  # CHANGED from 1375L, issue #143

  ## No NA coordinates or duplicate (id, waypoint) collisions among the
  ## new waypoint nodes.
  wpRows <- result$nodes[.isWaypoint(result$nodes$id), ]
  expect_false(any(is.na(wpRows$x)))
  expect_false(any(is.na(wpRows$y)))
  expect_false(any(duplicated(wpRows$id)))
})
