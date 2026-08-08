## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for makePedigreeDiagramData() -- issue #129 Slice 1. A pure
## function converting a pedigree data frame (id/sire/dam/sex/gen) into a
## visNetwork-ready list(nodes = data.frame(...), edges = data.frame(...)).

test_that("makePedigreeDiagramData rejects non-data-frame input", {
  expect_error(makePedigreeDiagramData(list(a = 1)), "data frame")
})

test_that(
  "makePedigreeDiagramData rejects a pedigree missing required columns", {
  noGen <- data.frame(id = "A", sire = NA, dam = NA, sex = "M",
                       stringsAsFactors = FALSE)
  expect_error(makePedigreeDiagramData(noGen), "gen")
})

test_that(
  "makePedigreeDiagramData returns nodes/edges with correct counts", {
  data("smallPed", package = "nprcgenekeepr")
  result <- makePedigreeDiagramData(smallPed)
  expect_true(is.list(result))
  expect_setequal(names(result), c("nodes", "edges"))
  expect_equal(nrow(result$nodes), nrow(smallPed))
  expectedEdges <- sum(!is.na(smallPed$sire)) + sum(!is.na(smallPed$dam))
  expect_equal(nrow(result$edges), expectedEdges)
})

test_that("makePedigreeDiagramData node ids match the pedigree ids", {
  data("smallPed", package = "nprcgenekeepr")
  result <- makePedigreeDiagramData(smallPed)
  expect_setequal(result$nodes$id, smallPed$id)
})

test_that("makePedigreeDiagramData maps gen to node level unchanged", {
  data("smallPed", package = "nprcgenekeepr")
  result <- makePedigreeDiagramData(smallPed)
  matched <- result$nodes$level[match(smallPed$id, result$nodes$id)]
  expect_equal(matched, smallPed$gen)
})

test_that(
  "makePedigreeDiagramData builds directed sire/dam edges (parent -> child)", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"),
    dam = c(NA, NA, "P2"),
    sex = factor(c("M", "F", "M"), levels = c("F", "M", "H", "U")),
    gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(trio)
  expect_equal(nrow(result$edges), 2L)
  expect_true(all(c("P1", "P2") %in% result$edges$from))
  expect_true(all(result$edges$to == "C1"))
})

test_that("makePedigreeDiagramData omits edges for unknown parents", {
  founder <- data.frame(
    id = "F1", sire = NA_character_, dam = NA_character_,
    sex = factor("F", levels = c("F", "M", "H", "U")), gen = 0L,
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(founder)
  expect_equal(nrow(result$edges), 0L)
  expect_equal(nrow(result$nodes), 1L)
})

test_that(
  "makePedigreeDiagramData maps sex to visNetwork shapes for all four levels", {
  ped <- data.frame(
    id = c("Fid", "Mid", "Hid", "Uid"),
    sire = NA_character_,
    dam = NA_character_,
    sex = factor(c("F", "M", "H", "U"), levels = c("F", "M", "H", "U")),
    gen = 0L,
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(ped)
  shapes <- setNames(result$nodes$shape, result$nodes$id)
  expect_equal(shapes[["Fid"]], "dot")
  expect_equal(shapes[["Mid"]], "square")
  expect_equal(shapes[["Hid"]], "star")
  expect_equal(shapes[["Uid"]], "triangle")
})

test_that("makePedigreeDiagramData scales correctly on examplePedigree", {
  ped <- nprcgenekeepr::examplePedigree
  result <- makePedigreeDiagramData(ped)
  expect_equal(nrow(result$nodes), nrow(ped))
  expectedEdges <- sum(!is.na(ped$sire)) + sum(!is.na(ped$dam))
  expect_equal(nrow(result$edges), expectedEdges)
})

## Issue #135 -- hover tooltips (node `title` field).

test_that("makePedigreeDiagramData adds a title field to nodes", {
  data("smallPed", package = "nprcgenekeepr")
  result <- makePedigreeDiagramData(smallPed)
  expect_true("title" %in% names(result$nodes))
  expect_equal(length(result$nodes$title), nrow(result$nodes))
})

test_that(
  "makePedigreeDiagramData's title includes id, sex, generation, sire, dam", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"),
    dam = c(NA, NA, "P2"),
    sex = factor(c("M", "F", "M"), levels = c("F", "M", "H", "U")),
    gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(trio)
  childTitle <- result$nodes$title[result$nodes$id == "C1"]
  expect_true(grepl("ID:</b> C1", childTitle, fixed = TRUE))
  expect_true(grepl("Sex:</b> Male", childTitle, fixed = TRUE))
  expect_true(grepl("Generation:</b> 1", childTitle, fixed = TRUE))
  expect_true(grepl("Sire:</b> P1", childTitle, fixed = TRUE))
  expect_true(grepl("Dam:</b> P2", childTitle, fixed = TRUE))
})

test_that(
  "makePedigreeDiagramData spells out sex in the title, matching the legend
   (issue #132)'s own Female/Male/Hermaphrodite/Unknown labels", {
  ped <- data.frame(
    id = c("Fid", "Mid", "Hid", "Uid"),
    sire = NA_character_,
    dam = NA_character_,
    sex = factor(c("F", "M", "H", "U"), levels = c("F", "M", "H", "U")),
    gen = 0L,
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(ped)
  titles <- setNames(result$nodes$title, result$nodes$id)
  expect_true(grepl("Sex:</b> Female", titles[["Fid"]], fixed = TRUE))
  expect_true(grepl("Sex:</b> Male", titles[["Mid"]], fixed = TRUE))
  expect_true(grepl("Sex:</b> Hermaphrodite", titles[["Hid"]], fixed = TRUE))
  expect_true(grepl("Sex:</b> Unknown", titles[["Uid"]], fixed = TRUE))
})

test_that(
  "makePedigreeDiagramData's title shows 'Other / Unrecorded' for an
   unmapped sex code, matching the legend's own label", {
  ped <- data.frame(
    id = "X1", sire = NA_character_, dam = NA_character_,
    sex = factor("Z", levels = c("F", "M", "H", "U", "Z")), gen = 0L,
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(ped)
  expect_true(
    grepl("Sex:</b> Other / Unrecorded", result$nodes$title, fixed = TRUE)
  )
})

test_that(
  "makePedigreeDiagramData's title shows Unknown for missing sire/dam", {
  founder <- data.frame(
    id = "F1", sire = NA_character_, dam = NA_character_,
    sex = factor("F", levels = c("F", "M", "H", "U")), gen = 0L,
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(founder)
  expect_true(grepl("Sire:</b> Unknown", result$nodes$title, fixed = TRUE))
  expect_true(grepl("Dam:</b> Unknown", result$nodes$title, fixed = TRUE))
})

test_that(
  "makePedigreeDiagramData's title HTML-escapes id/sire/dam text", {
  ped <- data.frame(
    id = c("A&B<C>", "Kid"),
    sire = c(NA, "A&B<C>"),
    dam = NA_character_,
    sex = factor(c("F", "M"), levels = c("F", "M", "H", "U")),
    gen = c(0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(ped)
  parentTitle <- result$nodes$title[result$nodes$id == "A&B<C>"]
  childTitle <- result$nodes$title[result$nodes$id == "Kid"]
  expect_false(grepl("A&B<C>", parentTitle, fixed = TRUE))
  expect_true(grepl("A&amp;B&lt;C&gt;", parentTitle, fixed = TRUE))
  expect_true(grepl("Sire:</b> A&amp;B&lt;C&gt;", childTitle, fixed = TRUE))
})

## Issue #133 -- affected/phenotype/genotype status encoding (D1-D8,
## docs/planning/issue133-affected-status-pedigree-diagram-plan.md).
## affected is an OPTIONAL logical column (TRUE/FALSE/NA). When present, an
## affected == TRUE node gets a dominant `color.background` (D3 Option 1,
## D8 color #CC79A7) and every node's tooltip gains an "Affected: Yes/No/
## Unknown" line (D3 Option 0). Absent column => zero change to today's
## output (backward compatible with every pre-#133 fixture/test).

test_that(
  "makePedigreeDiagramData sets color.background only for affected == TRUE
   rows when the affected column is present", {
  ped <- data.frame(
    id = c("A1", "A2", "A3"),
    sire = NA_character_, dam = NA_character_,
    sex = factor(c("F", "M", "F"), levels = c("F", "M", "H", "U")),
    gen = 0L,
    affected = c(TRUE, FALSE, NA),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(ped)
  expect_true("color.background" %in% names(result$nodes))
  colors <- setNames(result$nodes$color.background, result$nodes$id)
  expect_equal(colors[["A1"]], "#CC79A7")
  expect_true(is.na(colors[["A2"]]))
  expect_true(is.na(colors[["A3"]]))
})

test_that(
  "makePedigreeDiagramData's title gains an Affected: Yes/No/Unknown line
   matching each row's TRUE/FALSE/NA affected value", {
  ped <- data.frame(
    id = c("A1", "A2", "A3"),
    sire = NA_character_, dam = NA_character_,
    sex = factor(c("F", "M", "F"), levels = c("F", "M", "H", "U")),
    gen = 0L,
    affected = c(TRUE, FALSE, NA),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(ped)
  titles <- setNames(result$nodes$title, result$nodes$id)
  expect_true(grepl("Affected:</b> Yes", titles[["A1"]], fixed = TRUE))
  expect_true(grepl("Affected:</b> No", titles[["A2"]], fixed = TRUE))
  expect_true(grepl("Affected:</b> Unknown", titles[["A3"]], fixed = TRUE))
})

test_that(
  "makePedigreeDiagramData coerces a non-logical affected column via
   as.logical() (a raw CSV import may hand it character values) rather
   than erroring, matching kinship2's own NA-tolerant contract", {
  ped <- data.frame(
    id = c("A1", "A2", "A3"),
    sire = NA_character_, dam = NA_character_,
    sex = factor(c("F", "M", "F"), levels = c("F", "M", "H", "U")),
    gen = 0L,
    affected = c("TRUE", "FALSE", "not-a-value"),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(ped)
  colors <- setNames(result$nodes$color.background, result$nodes$id)
  expect_equal(colors[["A1"]], "#CC79A7")
  expect_true(is.na(colors[["A2"]]))
  expect_true(is.na(colors[["A3"]]))
})

test_that(
  "makePedigreeDiagramData produces byte-identical output for a ped with
   no affected column at all -- backward compatible with every pre-#133
   fixture/test", {
  trio <- data.frame(
    id = c("P1", "P2", "C1"),
    sire = c(NA, NA, "P1"),
    dam = c(NA, NA, "P2"),
    sex = factor(c("M", "F", "M"), levels = c("F", "M", "H", "U")),
    gen = c(0L, 0L, 1L),
    stringsAsFactors = FALSE
  )
  result <- makePedigreeDiagramData(trio)
  expect_false("color.background" %in% names(result$nodes))
  expect_false(any(grepl("Affected", result$nodes$title, fixed = TRUE)))
})
