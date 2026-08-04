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
   duplicate-node-arc fix, found S468)", {
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
                   c("id", "label", "shape", "title", "size", "x", "y"))
  expect_setequal(names(default$edges),
                   c("from", "to", "dashes", "smooth.enabled", "smooth.type",
                     "smooth.roundness"))
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
