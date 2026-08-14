## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for makePedigreeMatingLayout() -- Pedigree Diagram Option 2, Slice 3
## (docs/planning/pedigree-diagram-option2-layout-design-plan.md, Migration
## Path step 2). The new EXPORTED wrapper combining Slice 1's
## .buildMatingUnitForest() and Slice 2's .positionMatingUnitForest() into
## the visNetwork-ready list(nodes, edges) shape makePedigreeDiagramData()
## already returns, plus the duplicateNodeId -> realId lookup table D6
## needs. Edge routing (owner-directed, S461): direct parent -> union and
## union -> child edges, no waypoint nodes (issue #142 tracks the fuller
## rectilinear mate-line/sibship-bar style as a deferred, additive
## follow-up).

## ---- test helpers (not exported, local to this file) ------------------

.nodeKind <- function(ids) {
  ifelse(grepl("^__union_", ids), "union",
         ifelse(grepl("^__dup_", ids), "duplicate", "individual"))
}

## ---- input validation ---------------------------------------------------

test_that("makePedigreeMatingLayout rejects non-data-frame input", {
  expect_error(makePedigreeMatingLayout(list(a = 1)), "data frame")
})

test_that(
  "makePedigreeMatingLayout rejects a pedigree missing required columns", {
  noGen <- data.frame(id = "A", sire = NA, dam = NA, sex = "M",
                       stringsAsFactors = FALSE)
  expect_error(makePedigreeMatingLayout(noGen), "gen")
})

## ---- return shape ---------------------------------------------------

test_that(
  "makePedigreeMatingLayout returns a list with nodes/edges/duplicateToReal", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(trio)
  expect_true(is.list(result))
  expect_setequal(names(result), c("nodes", "edges", "duplicateToReal"))
})

## ---- node population: one row per real individual, duplicate, union ---

test_that(
  "makePedigreeMatingLayout's nodes has exactly one row per real
   individual, duplicate, and mating unit", {
  trio <- data.frame(
    id = c("P1", "P2", "C1", "C2", "C3"),
    sire = c(NA, NA, "P1", "P1", "P1"), dam = c(NA, NA, "P2", "P2", "P2"),
    sex = c("M", "F", "M", "F", "M"), gen = c(0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(trio)
  result <- makePedigreeMatingLayout(trio)
  expect_equal(nrow(result$nodes), nrow(trio) + nrow(forest$duplicates) +
                 nrow(forest$matingUnits))
  expect_setequal(result$nodes$id,
                   c(trio$id, forest$duplicates$id, forest$matingUnits$id))
})

## ---- shape/label: duplicates read as their real individual ------------

test_that(
  "makePedigreeMatingLayout maps sex to shape identically for a real
   individual and all of their duplicate nodes, matching
   makePedigreeDiagramData()'s own shape convention", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  dupIds <- forest$duplicates$id[forest$duplicates$realId == "8LKBV9"]
  expect_equal(length(dupIds), 2L)

  realShape <- result$nodes$shape[result$nodes$id == "8LKBV9"]
  dupShapes <- result$nodes$shape[result$nodes$id %in% dupIds]
  expect_equal(realShape, "square")
  expect_true(all(dupShapes == "square"))
})

test_that(
  "makePedigreeMatingLayout labels every real and duplicate node with the
   real individual's own id (a duplicate reads as that individual, not a
   synthetic id)", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  dupRows <- result$nodes[result$nodes$id %in% forest$duplicates$id, ]
  dupRealId <- forest$duplicates$realId[match(dupRows$id, forest$duplicates$id)]
  expect_equal(dupRows$label, dupRealId)

  realRows <- result$nodes[result$nodes$id %in% loopPed$id, ]
  expect_equal(realRows$label, realRows$id)
})

test_that(
  "makePedigreeMatingLayout gives union nodes an empty label and a size
   visibly smaller than real/duplicate nodes, so they don't read as an
   animal (D6, verified live via this session's own chromote POC)", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(trio)
  result <- makePedigreeMatingLayout(trio)
  unionRow <- result$nodes[result$nodes$id == forest$matingUnits$id, ]
  realRow <- result$nodes[result$nodes$id == "P1", ]
  expect_equal(unionRow$label, "")
  expect_true(unionRow$size < realRow$size)
})

## ---- title/tooltip content (D6) ----------------------------------------

test_that(
  "makePedigreeMatingLayout's title for a real individual matches
   makePedigreeDiagramData()'s own ID/Sex/Generation/Sire/Dam format", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = factor(c("M", "F", "M"), levels = c("F", "M", "H", "U")),
    gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(trio)
  childTitle <- result$nodes$title[result$nodes$id == "C1"]
  expect_true(grepl("ID:</b> C1", childTitle, fixed = TRUE))
  expect_true(grepl("Sex:</b> Male", childTitle, fixed = TRUE))
  expect_true(grepl("Generation:</b> 1", childTitle, fixed = TRUE))
  expect_true(grepl("Sire:</b> P1", childTitle, fixed = TRUE))
  expect_true(grepl("Dam:</b> P2", childTitle, fixed = TRUE))
})

test_that(
  "makePedigreeMatingLayout's title for a duplicate node repeats its real
   individual's own content plus a duplicate-occurrence cue", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = factor(c("M", "F", "F", "F", "M", "F", "F", "M"),
                 levels = c("F", "M", "H", "U")),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  realTitle <- result$nodes$title[result$nodes$id == "8LKBV9"]
  dupIds <- forest$duplicates$id[forest$duplicates$realId == "8LKBV9"]
  for (dupId in dupIds) {
    dupTitle <- result$nodes$title[result$nodes$id == dupId]
    expect_true(grepl("ID:</b> 8LKBV9", dupTitle, fixed = TRUE))
    expect_true(grepl("Sex:</b> Male", dupTitle, fixed = TRUE))
    expect_true(grepl("duplicate", dupTitle, ignore.case = TRUE))
  }
})

test_that(
  "makePedigreeMatingLayout's title for a union node reports its
   offspring count", {
  ped <- data.frame(
    id = c("P1", "P2", "C1", "C2", "C3"),
    sire = c(NA, NA, "P1", "P1", "P1"), dam = c(NA, NA, "P2", "P2", "P2"),
    sex = c("M", "F", "M", "F", "M"), gen = c(0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  result <- makePedigreeMatingLayout(ped)
  unionTitle <- result$nodes$title[result$nodes$id == forest$matingUnits$id]
  expect_true(grepl("3", unionTitle, fixed = TRUE))
})

## ---- edges: child edges, duplicate connectors, mate lines ---------------

test_that(
  "makePedigreeMatingLayout's edges include Slice 1's own child edges
   unchanged, with dashes = FALSE", {
  ped <- data.frame(
    id = c("P1", "P2", "C1", "C2", "C3"),
    sire = c(NA, NA, "P1", "P1", "P1"), dam = c(NA, NA, "P2", "P2", "P2"),
    sex = c("M", "F", "M", "F", "M"), gen = c(0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  result <- makePedigreeMatingLayout(ped)
  childRows <- result$edges[!result$edges$dashes &
                               result$edges$to %in% c("C1", "C2", "C3"), ]
  expect_setequal(paste(childRows$from, childRows$to),
                   paste(forest$childEdges$from, forest$childEdges$to))
})

test_that(
  "makePedigreeMatingLayout's edges include a dashed connector from each
   duplicate node to its real individual", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  ## A duplicate id can also be a mate-line edge's "from" (its solid edge
  ## to the union where it's positioned) -- filter to the DASHED connector
  ## specifically, not every edge originating from a duplicate id.
  dupConnectors <- result$edges[result$edges$from %in% forest$duplicates$id &
                                   result$edges$dashes, ]
  expect_equal(nrow(dupConnectors), nrow(forest$duplicates))
  expect_true(all(dupConnectors$dashes))
  expect_setequal(
    dupConnectors$to,
    forest$duplicates$realId[match(dupConnectors$from, forest$duplicates$id)]
  )
})

test_that(
  "makePedigreeMatingLayout's duplicate-node connector edges render as a
   curved arc (smooth.enabled = TRUE, smooth.type = \"curvedCW\"), visually
   distinct from the straight child/mate-line edges (smooth.enabled left NA,
   inheriting the widget's global smooth = FALSE) -- matches the kinship2/
   reference-pedigree convention of an arched dashed connector back to a
   duplicated individual's primary occurrence (found S468, fixed S469)", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  isDupConnector <- result$edges$from %in% forest$duplicates$id &
    result$edges$dashes
  dupConnectors <- result$edges[isDupConnector, ]
  otherEdges <- result$edges[!isDupConnector, ]
  expect_true(nrow(dupConnectors) > 0L)
  expect_true(all(c("smooth.enabled", "smooth.type") %in% names(result$edges)))
  expect_true(all(dupConnectors$smooth.enabled %in% TRUE))
  expect_true(all(dupConnectors$smooth.type %in% "curvedCW"))
  expect_true(all(is.na(otherEdges$smooth.enabled)))
})

test_that(
  "makePedigreeMatingLayout's duplicate-node connector arc survives
   edgeStyle = \"rectilinear\" -- .addRectilinearWaypoints() must not drop
   or misalign the new smooth.* columns when it rbinds its own fresh
   waypoint edges onto the passed-through direct-style edges (found S468,
   fixed S469)", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed, edgeStyle = "rectilinear")
  isDupConnector <- result$edges$from %in% forest$duplicates$id &
    result$edges$dashes
  dupConnectors <- result$edges[isDupConnector, ]
  expect_true(nrow(dupConnectors) > 0L)
  expect_true(all(c("smooth.enabled", "smooth.type") %in% names(result$edges)))
  expect_true(all(dupConnectors$smooth.enabled %in% TRUE))
  expect_true(all(dupConnectors$smooth.type %in% "curvedCW"))
})

test_that(
  "makePedigreeMatingLayout's edges include a solid mate-line edge from
   each mating unit's anchor AND non-anchor parent to the union node --
   using the non-anchor's DUPLICATE id when one was placed at this unit,
   so the mate-line reaches the node actually positioned there", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  mu <- forest$matingUnits

  for (i in seq_len(nrow(mu))) {
    unitId <- mu$id[i]
    mateEdges <- result$edges[!result$edges$dashes & result$edges$to == unitId, ]
    expect_equal(nrow(mateEdges), 2L, info = unitId)
    expect_true(mu$anchor[i] %in% mateEdges$from, info = unitId)

    dupRow <- which(forest$duplicates$realId == mu$nonAnchor[i] &
                       forest$duplicates$matingUnitId == unitId)
    expectedNonAnchorNode <- if (length(dupRow) == 1L) {
      forest$duplicates$id[dupRow]
    } else {
      mu$nonAnchor[i]
    }
    expect_true(expectedNonAnchorNode %in% mateEdges$from, info = unitId)
  }
})

## ---- x/y geometry: a deterministic, monotonic scale of Slice 2's own
## x/gen (not hardcoded scale constants, so a later visual-legibility
## tweak to the scale factor doesn't force a test rewrite) ----------------

test_that(
  "makePedigreeMatingLayout's y is a fixed positive linear scale of gen,
   and x is a fixed scale of Slice 2's own x", {
  ped <- data.frame(
    id = c("R1", "R2", sprintf("D%d", 1:4)),
    sire = c(NA, NA, "R1", "D1", "D2", "D3"),
    dam = c(NA, NA, "R2", NA, NA, NA),
    sex = c("M", "F", rep("M", 4)),
    gen = c(0L, 0L, 1:4),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  slice2Pos <- .positionMatingUnitForest(ped, forest)
  result <- makePedigreeMatingLayout(ped)

  merged <- merge(result$nodes, slice2Pos, by = "id", suffixes = c("", ".s2"))
  expect_true(nrow(merged) > 0L)

  ## y: a single positive scale factor recovers gen from y for every node.
  yScale <- unique(merged$y[merged$gen == 1L]) / 1L
  expect_length(yScale, 1L)
  expect_true(yScale > 0)
  expect_equal(merged$y, merged$gen * yScale)

  ## x: a single scale factor recovers Slice 2's own x for every node
  ## (skip if Slice 2's x happens to be all-zero for this fixture).
  nonZero <- which(abs(merged$x.s2) > 1e-9)
  skip_if(length(nonZero) == 0L, "no non-zero x in this fixture")
  xScale <- merged$x[nonZero[1L]] / merged$x.s2[nonZero[1L]]
  expect_true(xScale > 0)
  expect_equal(merged$x, merged$x.s2 * xScale)
})

## ---- duplicateToReal lookup ---------------------------------------------

test_that(
  "makePedigreeMatingLayout's duplicateToReal lookup matches Slice 1's own
   duplicates table exactly", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  expect_setequal(names(result$duplicateToReal), forest$duplicates$id)
  expect_equal(
    unname(result$duplicateToReal[forest$duplicates$id]),
    forest$duplicates$realId
  )
})

## ---- full real fixture (scale check) -------------------------------------

test_that(
  "makePedigreeMatingLayout on the full real 375-individual bundled
   fixture produces exactly the 740 nodes established by Slices 1/2, with
   no NA x/y and the expected edge composition", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  result <- makePedigreeMatingLayout(ped)

  expect_equal(nrow(result$nodes), 740L)
  expect_false(any(is.na(result$nodes$x)))
  expect_false(any(is.na(result$nodes$y)))

  expectedEdges <- nrow(forest$childEdges) + nrow(forest$duplicates) +
    2L * nrow(forest$matingUnits)
  expect_equal(nrow(result$edges), expectedEdges)
  expect_length(result$duplicateToReal, nrow(forest$duplicates))
})

## ---- edgeStyle parameter (issue #142 Slice 2) ---------------------------

test_that(
  "makePedigreeMatingLayout defaults to edgeStyle = \"direct\" -- identical
   to calling with edgeStyle explicitly \"direct\", no waypoint ids, and no
   edge columns beyond the existing contract plus the duplicate-connector
   arc's smooth.* override columns (contract updated S469 for the
   duplicate-node-arc fix, found S468) plus color/width (S549 Finding #2,
   fixed S555 -- ALWAYS present once any mating unit exists, since
   consanguinity is a structural fact of the required sire/dam columns,
   unlike the optional name/twinRelations sidecars; both NA here since
   this fixture has no consanguineous mating) and color.background (Track
   1, docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md,
   found S569 -- ALWAYS present now, unconditional on the affected column's
   presence)", {
  ped <- data.frame(
    id = c("R1", "R2", sprintf("D%d", 1:4)),
    sire = c(NA, NA, "R1", "D1", "D2", "D3"),
    dam = c(NA, NA, "R2", NA, NA, NA),
    sex = c("M", "F", rep("M", 4L)),
    gen = c(0L, 0L, 1:4),
    stringsAsFactors = FALSE
  )
  default <- makePedigreeMatingLayout(ped)
  explicit <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
  expect_equal(default, explicit)
  expect_false(any(grepl("^__drop_|^__bar_|^__proj_", default$nodes$id)))
  expect_setequal(names(default$nodes),
                   c("id", "label", "shape", "title", "size",
                     "color.background", "x", "y"))
  expect_setequal(names(default$edges),
                   c("from", "to", "dashes", "smooth.enabled", "smooth.type",
                     "smooth.roundness", "color", "width"))
})

test_that(
  "makePedigreeMatingLayout rejects an invalid edgeStyle value", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  expect_error(makePedigreeMatingLayout(trio, edgeStyle = "curvy"),
               "should be one of")
})

test_that(
  "makePedigreeMatingLayout with edgeStyle = \"rectilinear\" produces
   exactly the same result as calling .addRectilinearWaypoints() directly
   on the direct-style output (confirms the wiring, not a reimplementation
   of Slice 1's own already-tested waypoint geometry)", {
  ped <- data.frame(
    id = c("P1", "P2", "C1", "C2", "C3"),
    sire = c(NA, NA, "P1", "P1", "P1"), dam = c(NA, NA, "P2", "P2", "P2"),
    sex = c("M", "F", "M", "F", "M"), gen = c(0L, 0L, 1L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  direct <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
  expected <- .addRectilinearWaypoints(direct$nodes, direct$edges, forest,
                                        pos)

  result <- makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")
  expect_equal(result$nodes, expected$nodes)
  expect_equal(result$edges, expected$edges)
  expect_equal(result$duplicateToReal, direct$duplicateToReal)
  expect_true(any(grepl("^__drop_|^__bar_", result$nodes$id)))
})

test_that(
  "makePedigreeMatingLayout on the full real 375-individual bundled
   fixture produces exactly 1,228 nodes under edgeStyle = \"rectilinear\"
   (issue #143's fix resolved all 96 non-anchor D2 mismatches, dropping
   the D2 projection count from 147 to 51; issue #144's fix now resolves
   those remaining 51 anchor-side ones too, dropping the projection count
   to 0 -- CHANGED from 1279L; re-confirmed through the actual public
   entry point, not just Slice 1's internal helper)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")
  expect_equal(nrow(result$nodes), 1228L)
  expect_false(any(is.na(result$nodes$x)))
  expect_false(any(is.na(result$nodes$y)))
})

## ---- orderBySex parameter (issue #145 Slice 1, D8 option (b)) ----------
## docs/planning/issue145-sire-dam-left-right-placement-plan.md. Threads
## through to .positionMatingUnitForest()'s own new orderBySex argument
## (tests/testthat/test_positionMatingUnitForest.R carries the actual
## positioning-mechanism coverage) -- this section confirms the WIRING at
## the exported entry point only, mirroring the edgeStyle precedent above.

test_that(
  "makePedigreeMatingLayout defaults to orderBySex = TRUE -- identical to
   calling with orderBySex explicitly TRUE, and produces a different
   result than orderBySex = FALSE for a pair that needs the swap", {
  ## AM (sire, 'M') < ZF (dam, 'F') lexically -> AM anchors -> pre-#145,
  ## AM ends up right of ZF -- the swap-needing case (matches
  ## test_positionMatingUnitForest.R's own AM/ZF fixture).
  ped <- data.frame(
    id = c("AM", "ZF", "K"),
    sire = c(NA, NA, "AM"), dam = c(NA, NA, "ZF"),
    sex = c("M", "F", "F"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  default <- makePedigreeMatingLayout(ped)
  explicit <- makePedigreeMatingLayout(ped, orderBySex = TRUE)
  legacy <- makePedigreeMatingLayout(ped, orderBySex = FALSE)
  expect_equal(default, explicit)
  expect_false(isTRUE(all.equal(default$nodes$x, legacy$nodes$x)))

  amX <- default$nodes$x[default$nodes$id == "AM"]
  zfX <- default$nodes$x[default$nodes$id == "ZF"]
  expect_true(amX < zfX)
})

test_that(
  "makePedigreeMatingLayout with orderBySex = FALSE produces exactly the
   same nodes as calling .positionMatingUnitForest() directly with
   orderBySex = FALSE (confirms the wiring, not a reimplementation of
   Slice 1's own already-tested positioning mechanism)", {
  ped <- data.frame(
    id = c("AM", "ZF", "K"),
    sire = c(NA, NA, "AM"), dam = c(NA, NA, "ZF"),
    sex = c("M", "F", "F"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest, orderBySex = FALSE)
  result <- makePedigreeMatingLayout(ped, orderBySex = FALSE)

  ## makePedigreeMatingLayout() scales .positionMatingUnitForest()'s raw x
  ## by its own xScale (120L, R/makePedigreeDiagramData.R:1049) for
  ## rendering -- compare post-scale, not raw.
  xScale <- 120L
  expect_equal(sort(result$nodes$x[result$nodes$id %in% pos$id]),
               sort(pos$x * xScale), tolerance = 1e-6)
})

## ---- Issue #133 -- affected/phenotype/genotype status encoding (D1-D8,
## docs/planning/issue133-affected-status-pedigree-diagram-plan.md) --------
## Independent implementation of the same optional-column contract
## makePedigreeDiagramData() gets (D4 -- this function, not that one, is
## what the live Diagram tab actually renders, R/modPedigree.R:446).
## Duplicate nodes inherit their real individual's color (matching how
## they already inherit shape/title); mating-unit nodes get no coloring
## (a union is not an individual).
##
## Track 1 (docs/planning/pedigree-diagram-kinship2-fidelity-remediation-
## plan.md, found S569): an ABSENT affected column no longer leaves
## color.background unset on real/duplicate nodes -- they now get an
## explicit white (#FFFFFF) fill unconditionally, matching kinship2's own
## "unfilled" default. Mating-unit dot nodes stay NA either way (owner
## decision, S570) -- they are not individuals and were never part of the
## affected-status convention. The tooltip's Affected line is unaffected
## by this change -- still absent when the column itself is absent.

test_that(
  "makePedigreeMatingLayout sets color.background for affected == TRUE real
   individuals, propagates the same color to their duplicate nodes, and
   leaves mating-unit nodes uncolored (D4)", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    affected = c(TRUE, FALSE, NA, FALSE, TRUE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  expect_true("color.background" %in% names(result$nodes))

  realColor <- result$nodes$color.background[result$nodes$id == "8LKBV9"]
  expect_equal(realColor, "#CC79A7")

  dupIds <- forest$duplicates$id[forest$duplicates$realId == "8LKBV9"]
  dupColors <- result$nodes$color.background[result$nodes$id %in% dupIds]
  expect_true(length(dupColors) > 0L)
  expect_true(all(dupColors == "#CC79A7"))

  unitColor <- result$nodes$color.background[
    result$nodes$id %in% forest$matingUnits$id
  ]
  expect_true(length(unitColor) > 0L)
  expect_true(all(is.na(unitColor)))
})

test_that(
  "makePedigreeMatingLayout's title for a real individual and every one of
   its duplicate nodes both gain the Affected: Yes/No/Unknown line", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    affected = c(TRUE, FALSE, NA, FALSE, TRUE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  realTitle <- result$nodes$title[result$nodes$id == "8LKBV9"]
  expect_true(grepl("Affected:</b> Yes", realTitle, fixed = TRUE))

  dupIds <- forest$duplicates$id[forest$duplicates$realId == "8LKBV9"]
  for (dupId in dupIds) {
    dupTitle <- result$nodes$title[result$nodes$id == dupId]
    expect_true(grepl("Affected:</b> Yes", dupTitle, fixed = TRUE))
  }

  unaffectedTitle <- result$nodes$title[result$nodes$id == "8DKELJ"]
  expect_true(grepl("Affected:</b> No", unaffectedTitle, fixed = TRUE))
  unknownTitle <- result$nodes$title[result$nodes$id == "G8EBU9"]
  expect_true(grepl("Affected:</b> Unknown", unknownTitle, fixed = TRUE))
})

test_that(
  "makePedigreeMatingLayout coerces a non-logical affected column via
   as.logical() rather than erroring", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    affected = c("TRUE", "FALSE", "nonsense"),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(trio)
  realRows <- result$nodes[result$nodes$id %in% trio$id, ]
  colors <- setNames(realRows$color.background, realRows$id)
  expect_equal(colors[["P1"]], "#CC79A7")
  expect_equal(colors[["P2"]], "#FFFFFF")
  expect_equal(colors[["C1"]], "#FFFFFF")
})

test_that(
  "makePedigreeMatingLayout defaults every real/duplicate node to an
   explicit white (#FFFFFF) color.background when the ped has no affected
   column at all (Track 1, docs/planning/pedigree-diagram-kinship2-
   fidelity-remediation-plan.md), leaves mating-unit dot nodes NA, and
   leaves the tooltip's Affected line absent, unchanged", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(trio)
  expect_true("color.background" %in% names(result$nodes))

  realRows <- result$nodes[result$nodes$id %in% trio$id, ]
  expect_true(all(realRows$color.background == "#FFFFFF"))

  unitRows <- result$nodes[!(result$nodes$id %in% trio$id), ]
  expect_true(nrow(unitRows) > 0L)
  expect_true(all(is.na(unitRows$color.background)))

  expect_false(any(grepl("Affected", result$nodes$title, fixed = TRUE)))
})

test_that(
  "makePedigreeMatingLayout's affected-status color.background survives
   edgeStyle = \"rectilinear\" -- .addRectilinearWaypoints() must preserve
   pre-existing node coloring rather than reset it to NA (found this
   session reading R/makePedigreeDiagramData.R:1117-1119 -- a blanket
   overwrite that would otherwise silently erase Slice 1's own coloring
   the moment the Diagram tab is switched to rectilinear mode)", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    affected = c(TRUE, FALSE, NA, FALSE, TRUE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(loopPed, edgeStyle = "rectilinear")
  expect_true("color.background" %in% names(result$nodes))

  realColor <- result$nodes$color.background[result$nodes$id == "8LKBV9"]
  expect_equal(realColor, "#CC79A7")

  ## Waypoint nodes keep their own, unrelated fully-transparent contract
  ## (issue #142) -- unaffected by #133's coloring.
  waypointRows <- result$nodes[grepl("^__drop_|^__bar_|^__proj_",
                                      result$nodes$id), ]
  expect_true(nrow(waypointRows) > 0L)
  expect_true(all(waypointRows$color.background == "rgba(0,0,0,0)"))
})

test_that(
  "makePedigreeMatingLayout's Track 1 default white fill survives
   edgeStyle = \"rectilinear\" for a ped with no affected column at all --
   .addRectilinearWaypoints() must preserve it rather than reset to NA,
   same precedent as the affected-column case above", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(loopPed, edgeStyle = "rectilinear")
  expect_true("color.background" %in% names(result$nodes))

  realColor <- result$nodes$color.background[result$nodes$id == "8LKBV9"]
  expect_equal(realColor, "#FFFFFF")

  ## Waypoint nodes keep their own, unrelated fully-transparent contract
  ## (issue #142) -- unaffected by Track 1's coloring.
  waypointRows <- result$nodes[grepl("^__drop_|^__bar_|^__proj_",
                                      result$nodes$id), ]
  expect_true(nrow(waypointRows) > 0L)
  expect_true(all(waypointRows$color.background == "rgba(0,0,0,0)"))
})

## Issue #136 -- name (non-ID) node labels, Slice 2 (D3/D4/D5/D7/D10,
## docs/planning/issue136-name-labels-pedigree-diagram-plan.md). Mirrors
## makePedigreeDiagramData()'s own contract (D7: implement in both), but
## also covers the duplicate-node label-parity DONE criterion this function
## alone is responsible for (a real individual's duplicate occurrences must
## read as that individual, name included, not just their bare id -- :906's
## existing precedent for the id-only case).

test_that(
  "makePedigreeMatingLayout augments a real individual's label with its
   name, two-line 'id\\nname' form (D3), when a name column is present", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    name = c("Apollo", "Willow", NA_character_),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(trio)
  labels <- setNames(result$nodes$label, result$nodes$id)
  expect_equal(labels[["P1"]], "P1\nApollo")
  expect_equal(labels[["P2"]], "P2\nWillow")
  expect_equal(labels[["C1"]], "C1")  ## D4 fallback -- NA name
})

test_that(
  "makePedigreeMatingLayout gives a duplicate-occurrence node the SAME
   augmented label as its real individual (D7 parity) -- a duplicate must
   read as that individual, name included, not just its bare id", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    name = c(NA, NA, NA, NA, "Kepler", NA, NA, NA),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  result <- makePedigreeMatingLayout(loopPed)
  dupIds <- forest$duplicates$id[forest$duplicates$realId == "8LKBV9"]
  expect_equal(length(dupIds), 2L)

  realLabel <- result$nodes$label[result$nodes$id == "8LKBV9"]
  dupLabels <- result$nodes$label[result$nodes$id %in% dupIds]
  expect_equal(realLabel, "8LKBV9\nKepler")
  expect_true(all(dupLabels == "8LKBV9\nKepler"))
})

test_that(
  "makePedigreeMatingLayout leaves a mating-union node's label empty (D11)
   regardless of whether a name column is present -- a union is not an
   individual", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    name = c("Apollo", "Willow", "Comet"),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(trio)
  result <- makePedigreeMatingLayout(trio)
  unionRow <- result$nodes[result$nodes$id == forest$matingUnits$id, ]
  expect_equal(unionRow$label, "")
})

test_that(
  "makePedigreeMatingLayout truncates a name longer than the 15-character
   budget with an ellipsis (D10), and carries the FULL, un-truncated,
   HTML-escaped name in the tooltip", {
  longName <- "Grand-Champion-Xerxes-Constantinopolous-The-Magnificent-III"
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    name = c(longName, NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(trio)
  label <- result$nodes$label[result$nodes$id == "P1"]
  title <- result$nodes$title[result$nodes$id == "P1"]
  expect_equal(label, paste0("P1\n", substr(longName, 1L, 15L), "..."))
  expect_true(grepl(paste0("Name:</b> ", longName), title, fixed = TRUE))
})

test_that(
  "makePedigreeMatingLayout produces byte-identical labels/titles for a ped
   with no name column at all -- backward compatible with every pre-#136
   fixture/test (the existing pins at :112,115,132,437-438 all still
   hold)", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"), gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(trio)
  realRows <- result$nodes[result$nodes$id %in% trio$id, ]
  expect_equal(realRows$label, realRows$id)
  expect_false(any(grepl("Name:", result$nodes$title, fixed = TRUE)))
})

## Issue #137 -- twin/zygosity connector edges, Slice 2 (D6/D7/D9,
## docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md). Mirrors
## makePedigreeDiagramData()'s own D6 styling contract, plus this function's
## own two extra obligations: D7 (a twin connector always targets the two
## individuals' REAL node ids, never a __dup_ occurrence, even when one twin
## is also a duplicated multi-mate parent elsewhere in the diagram) and D9
## (.addRectilinearWaypoints()'s newEdges construction must not crash with
## "undefined columns selected" when twin data adds a new `label` edge
## column). twinRelations is NOT validated internally (checkTwinRelations()
## is a caller-side concern, same precedent cited in
## test_makePedigreeDiagramData.R). The default-vs-explicit exact-edge-
## -column-names backward-compat guard already at :419-442 above continues
## to hold unmodified -- twinRelations absent adds no new columns.

test_that(
  "makePedigreeMatingLayout adds a distinctly-styled MZ/DZ/UZ connector edge
   per twin pair on the real Slice 1 fixture pair, using kinship2's own
   'MZ'/'DZ'/'?' labels, all sharing the same Okabe-Ito #009E73 color (D6,
   D10, found unwired S494, fixed S506)", {
  ped <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped_twins.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  twinRelations <- read.csv(
    system.file("extdata", "examples",
                "obfuscated_rhesus_mhc_twin_relations.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(ped, twinRelations = twinRelations)
  connectors <- result$edges[!is.na(result$edges$label), ]
  expect_equal(nrow(connectors), 3L)

  mz <- connectors[connectors$from == "E06FRB", ]
  expect_equal(mz$to, "HV7LZ3")
  expect_equal(mz$label, "MZ")
  expect_identical(mz$dashes[[1L]], FALSE)
  expect_equal(mz$color, "#009E73")

  dz <- connectors[connectors$from == "8GSXTQ", ]
  expect_equal(dz$to, "P844CW")
  expect_equal(dz$label, "DZ")
  expect_identical(dz$dashes[[1L]], c(4L, 4L))
  expect_equal(dz$color, "#009E73")

  uz <- connectors[connectors$from == "BRI2MW", ]
  expect_equal(uz$to, "677E7M")
  expect_equal(uz$label, "?")
  expect_identical(uz$dashes[[1L]], c(14L, 8L))
  expect_equal(uz$color, "#009E73")
})

test_that(
  "makePedigreeMatingLayout's twin connector targets the two individuals'
   REAL node ids, never a __dup_ occurrence id, even when one twin is also
   a duplicated multi-mate parent elsewhere in the diagram (D7, Dragon 3)", {
  ## TW1 mates with both M1 and M2 (2 distinct mating units) -- Slice 1's
  ## own .buildMatingUnitForest() anchors M1/M2 (fewer total mating units)
  ## and gives TW1 a real "free" occurrence at one unit plus a __dup_TW1_1
  ## node at the other. TW2 is TW1's MZ twin, unrelated to any mating unit.
  ## This ped deliberately does NOT satisfy checkTwinRelations()'s own
  ## shared-parents/matching-sex domain rules -- the render function does
  ## not validate twinRelations (see file-header comment above), so this
  ## test exercises rendering mechanics only, not domain validity.
  d7Ped <- data.frame(
    id = c("TW1", "TW2", "M1", "M2", "C1", "C2"),
    sire = c(NA, NA, NA, NA, "M1", "M2"),
    dam  = c(NA, NA, NA, NA, "TW1", "TW1"),
    sex = c("F", "F", "M", "M", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  twinRelations <- data.frame(
    id1 = "TW1", id2 = "TW2", code = "MZ twin", stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(d7Ped)
  expect_true(any(forest$duplicates$realId == "TW1"))  ## sanity: Dragon 3
                                                          ## scenario is real

  result <- makePedigreeMatingLayout(d7Ped, twinRelations = twinRelations)
  connector <- result$edges[result$edges$label %in% "MZ", ]
  expect_equal(nrow(connector), 1L)
  expect_equal(connector$from, "TW1")
  expect_equal(connector$to, "TW2")
  expect_false(grepl("^__dup_", connector$from))
  expect_false(grepl("^__dup_", connector$to))
  expect_equal(connector$color, "#009E73")

  ## Pre-existing child/mate edges gain label = NA and color = NA alongside
  ## the connector.
  nonConnector <- result$edges[!result$edges$label %in% "MZ", ]
  expect_true(all(is.na(nonConnector$label)))
  expect_true(all(is.na(nonConnector$color)))
})

test_that(
  "makePedigreeMatingLayout's edgeStyle = \"rectilinear\" does not crash
   with 'undefined columns selected' when twinRelations is present (D9) --
   the connector edge passes through unchanged, since it is not part of
   .buildMatingUnitForest()'s childEdges/matingUnits structure the waypoint
   routing logic rewrites, and keeps its #009E73 color -- Dragon: found
   S506, .addRectilinearWaypoints() blanket-reset every kept edge's color
   to NA before this fix", {
  d7Ped <- data.frame(
    id = c("TW1", "TW2", "M1", "M2", "C1", "C2"),
    sire = c(NA, NA, NA, NA, "M1", "M2"),
    dam  = c(NA, NA, NA, NA, "TW1", "TW1"),
    sex = c("F", "F", "M", "M", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 1L),
    stringsAsFactors = FALSE
  )
  twinRelations <- data.frame(
    id1 = "TW1", id2 = "TW2", code = "MZ twin", stringsAsFactors = FALSE
  )
  result <- expect_error(
    makePedigreeMatingLayout(d7Ped, edgeStyle = "rectilinear",
                              twinRelations = twinRelations),
    NA
  )
  connector <- result$edges[result$edges$label %in% "MZ", ]
  expect_equal(nrow(connector), 1L)
  expect_equal(connector$from, "TW1")
  expect_equal(connector$to, "TW2")
  expect_identical(connector$dashes[[1L]], FALSE)
  expect_identical(connector$color, "#009E73")
})

## ---- Finding #2 (S549 kinship2 supplement audit): consanguineous-mating
## visual marker (BACKLOG.md Housekeeping) -- kinship2's own plot method
## draws a mating between two blood-related individuals with a doubled/
## thickened connecting line; makePedigreeMatingLayout() renders every
## mating unit identically regardless of kinship(sire, dam). Detected
## directly from the sire/dam/gen columns this function already requires
## (a structural fact of the pedigree, unlike the optional name/
## twinRelations sidecars above) -- not gated behind a UI toggle, matching
## kinship2's own unconditional convention. Styling: Okabe-Ito colorblind-
## safe vermillion (#D55E00, unused elsewhere in this file -- #009E73 is
## the twin connector, #CC79A7 is affected, #2B7CE9 is the waypoint-edge
## blue) plus a thicker width (4 vs vis.js's own default ~1), applied to
## the 2 spouse-to-union mate-line edges. Scoped to edgeStyle = "direct"
## this session (owner-directed hold, S555) -- edgeStyle = "rectilinear"
## propagation is a follow-up BACKLOG item.

test_that(
  "makePedigreeMatingLayout marks the 2 mate-line edges of a
   consanguineous mating unit (kinship(sire, dam) > 0) with a distinct
   color/width, using the real loop fixture's own genuine father-daughter
   mating (8LKBV9 x FJIB3R, kinship = 0.25)", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  consanguineousUnit <- forest$matingUnits$id[
    forest$matingUnits$sire == "8LKBV9" & forest$matingUnits$dam == "FJIB3R"
  ]
  expect_equal(length(consanguineousUnit), 1L)

  result <- makePedigreeMatingLayout(loopPed)
  expect_true("color" %in% names(result$edges))
  expect_true("width" %in% names(result$edges))
  mateEdges <- result$edges[result$edges$to == consanguineousUnit, ]
  expect_equal(nrow(mateEdges), 2L)
  expect_equal(mateEdges$color, rep("#D55E00", 2L))
  expect_equal(mateEdges$width, rep(4, 2L))
})

test_that(
  "makePedigreeMatingLayout leaves every mate-line edge of a
   NON-consanguineous mating unit at NA color/width, even on a fixture
   that has one genuinely consanguineous unit elsewhere (selective
   marking, not a blanket style change)", {
  loopPed <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(loopPed)
  consanguineousUnit <- forest$matingUnits$id[
    forest$matingUnits$sire == "8LKBV9" & forest$matingUnits$dam == "FJIB3R"
  ]
  otherUnits <- setdiff(forest$matingUnits$id, consanguineousUnit)
  expect_equal(length(otherUnits), 3L)

  result <- makePedigreeMatingLayout(loopPed)
  expect_true("color" %in% names(result$edges))
  expect_true("width" %in% names(result$edges))
  otherMateEdges <- result$edges[result$edges$to %in% otherUnits, ]
  expect_equal(nrow(otherMateEdges), 6L)
  expect_equal(otherMateEdges$color, rep(NA_character_, 6L))
  expect_equal(otherMateEdges$width, rep(NA_real_, 6L))
})

test_that(
  "makePedigreeMatingLayout leaves every mate-line edge at NA color/width
   on a pedigree with no consanguineous mating at all (no false
   positives)", {
  ped <- data.frame(
    id = c("R1", "R2", sprintf("D%d", 1:4)),
    sire = c(NA, NA, "R1", "D1", "D2", "D3"),
    dam = c(NA, NA, "R2", NA, NA, NA),
    sex = c("M", "F", rep("M", 4L)),
    gen = c(0L, 0L, 1:4),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeMatingLayout(ped)
  expect_true("color" %in% names(result$edges))
  expect_true("width" %in% names(result$edges))
  mateEdges <- result$edges[!result$edges$dashes, ]
  expect_true(nrow(mateEdges) > 0L)
  expect_true(all(is.na(mateEdges$color)))
  expect_true(all(is.na(mateEdges$width)))
})

test_that(
  "makePedigreeMatingLayout never treats a mating unit with a dangling
   (no own row in 'ped') parent as consanguineous -- kinship() cannot be
   evaluated for an id absent from 'ped', so the safe default is FALSE,
   and no crash occurs (mirrors the issue #154 dangling-parent precedent
   already established for the D2 dogleg loop)", {
  ped <- data.frame(
    id = c("GRANDSIRE", "SIRE", "CHILD"),
    sire = c(NA, "GRANDSIRE", "SIRE"),
    dam = c(NA, NA, "DANGLING_DAM"),
    sex = c("M", "M", "F"),
    gen = c(0L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  result <- expect_error(makePedigreeMatingLayout(ped), NA)
  expect_true("color" %in% names(result$edges))
  expect_true("width" %in% names(result$edges))
  mateEdges <- result$edges[!result$edges$dashes, ]
  expect_true(nrow(mateEdges) > 0L)
  expect_true(all(is.na(mateEdges$color)))
  expect_true(all(is.na(mateEdges$width)))
})

## ---- Track C (kinship2 supplement full-reproduction plan,
## docs/planning/kinship2-supplement-full-reproduction-plan.md §5; S549
## Finding #2's own deferred follow-up, BACKLOG.md Housekeeping): finish
## edgeStyle = "rectilinear" consanguineous-marker propagation onto D2
## dogleg-rerouted projection edges. When a marked mate edge's own parent
## sits at a different generation than its mating unit (because that
## parent also anchors a 2nd, differently-gen'd unit elsewhere --
## .addRectilinearWaypoints()'s own D2 loop), the loop currently builds 2
## new projection edges without looking up the original edge's color/width
## first, so they fall through to the generic #2B7CE9/NA fallback instead
## of carrying the consanguinity marker onto the reroute. Fixture: A and Y
## are full siblings (children of P1 x P2, kinship = 0.5); A x Y is the
## consanguineous union under test. A is ALSO the anchor of a 2nd, unrelated
## union (A x X, X a founder with gen = 3) processed earlier, and Y is
## ALSO the anchor of a 3rd, unrelated union (Y x W) processed earlier too
## -- both already "used" by the time A x Y is processed, so the D2
## anchor-preference tie-break (tied founder status, tied mate count) falls
## to ascending id ("A" < "Y"), and A wins anchor of the consanguineous
## union. A's own displayed gen is then the MAX across every unit A
## anchors (3, from A x X) -- differing from the consanguineous union's own
## gen (1, pmax(A's gen = 1, Y's gen = 1)) -- forcing exactly one dogleg,
## on A's own side. Verified empirically this session (S563): direct-style
## correctly marks both mate edges (#D55E00/4); rectilinear-style currently
## drops the marker on A's doglegged side (falls to #2B7CE9/NA) while Y's
## non-doglegged duplicate-node side keeps it correctly (pinned to the
## union's own gen, issue #143/#144's own precedent) -- confirming the
## propagation gap is real and selective (not a blanket regression).

test_that(
  "makePedigreeMatingLayout (edgeStyle = \"rectilinear\") propagates a
   consanguineous mating unit's color/width marker onto its D2
   dogleg-rerouted projection edges, not just the un-doglegged side", {
  ped <- data.frame(
    id   = c("P1", "P2", "A", "Y", "X", "W", "C1", "C2", "GC"),
    sire = c(NA, NA, "P1", "P1", NA, NA, "A", "Y", "A"),
    dam  = c(NA, NA, "P2", "P2", NA, NA, "X", "W", "Y"),
    sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M"),
    gen  = c(0L, 0L, 1L, 1L, 3L, 1L, 4L, 2L, 2L),
    stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(ped)
  consangUnit <- forest$matingUnits$id[
    forest$matingUnits$sire == "A" & forest$matingUnits$dam == "Y"
  ]
  expect_equal(length(consangUnit), 1L)
  expect_equal(forest$matingUnits$anchor[forest$matingUnits$id == consangUnit],
               "A")

  result <- makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")
  projNodeId <- sprintf("__proj_A_%s", consangUnit)
  expect_true(projNodeId %in% result$nodes$id)

  ## A's side: the 2 new projection edges (A -> proj, proj -> union) must
  ## carry the SAME marker the original A -> union edge had, not the
  ## generic waypoint-edge fallback.
  fromEdge <- result$edges[result$edges$from == "A" &
                              result$edges$to == projNodeId, ]
  toEdge <- result$edges[result$edges$from == projNodeId &
                             result$edges$to == consangUnit, ]
  expect_equal(nrow(fromEdge), 1L)
  expect_equal(nrow(toEdge), 1L)
  expect_equal(fromEdge$color, "#D55E00")
  expect_equal(fromEdge$width, 4)
  expect_equal(toEdge$color, "#D55E00")
  expect_equal(toEdge$width, 4)

  ## Y's side never doglegs (her duplicate node is pinned to the union's
  ## own gen) -- her edge must still carry the marker too, confirming the
  ## fix is additive, not a reshuffle of which side keeps it.
  yEdge <- result$edges[grepl("^__dup_Y_", result$edges$from) &
                            result$edges$to == consangUnit, ]
  expect_equal(nrow(yEdge), 1L)
  expect_equal(yEdge$color, "#D55E00")
  expect_equal(yEdge$width, 4)
})

test_that(
  "makePedigreeMatingLayout's consanguinity marker coexists correctly
   with twinRelations (D6/D7's own twin connector edges) -- no column
   conflict, no crash, both features render independently", {
  ## Extends the existing D7 twin-connector fixture (:857-864 above) with
  ## one added consanguineous mating: TW1 (already TW2's declared MZ
  ## twin, mating with unrelated M1/M2) ALSO mates with her own daughter
  ## C1 (from the TW1 x M1 union) to produce C3.
  d7Ped <- data.frame(
    id = c("TW1", "TW2", "M1", "M2", "C1", "C2", "C3"),
    sire = c(NA, NA, NA, NA, "M1", "M2", "TW1"),
    dam  = c(NA, NA, NA, NA, "TW1", "TW1", "C1"),
    sex = c("F", "F", "M", "M", "F", "M", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  twinRelations <- data.frame(
    id1 = "TW1", id2 = "TW2", code = "MZ twin", stringsAsFactors = FALSE
  )
  forest <- .buildMatingUnitForest(d7Ped)
  consanguineousUnit <- forest$matingUnits$id[
    forest$matingUnits$sire == "TW1" & forest$matingUnits$dam == "C1"
  ]
  expect_equal(length(consanguineousUnit), 1L)

  result <- expect_error(
    makePedigreeMatingLayout(d7Ped, twinRelations = twinRelations), NA
  )

  ## The twin connector still renders correctly, unaffected.
  connector <- result$edges[result$edges$label %in% "MZ", ]
  expect_equal(nrow(connector), 1L)
  expect_equal(connector$color, "#009E73")

  ## The consanguineous union's own mate edges are marked, distinctly
  ## from the twin connector's color. (result$edges$dashes is a list
  ## column here -- twinRelations makes some rows carry a numeric dash
  ## pattern -- so filter by 'to' alone, not '!dashes'.)
  mateEdges <- result$edges[result$edges$to == consanguineousUnit, ]
  expect_equal(nrow(mateEdges), 2L)
  expect_equal(mateEdges$color, rep("#D55E00", 2L))
  expect_equal(mateEdges$width, rep(4, 2L))
})
