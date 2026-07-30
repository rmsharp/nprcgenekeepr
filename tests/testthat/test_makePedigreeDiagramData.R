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
