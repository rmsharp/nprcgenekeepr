#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Dedicated unit tests for getAncestors(), which had no direct test coverage.
#' getAncestors() recursively returns the sire-then-dam lineage for an ID,
#' given a pedigree tree (list of id -> list(sire, dam)).

ptree <- list(
  A = list(sire = NA_character_, dam = NA_character_),
  B = list(sire = NA_character_, dam = NA_character_),
  C = list(sire = "A", dam = "B"),
  D = list(sire = "A", dam = "B"),
  E = list(sire = "C", dam = "D")
)

test_that("getAncestors returns character(0) for a founder", {
  expect_identical(getAncestors("A", ptree), character(0))
})

test_that("getAncestors returns character(0) for a missing (NA) ID", {
  expect_identical(getAncestors(NA_character_, ptree), character(0))
})

test_that("getAncestors returns both parents for a one-generation ID", {
  expect_identical(getAncestors("C", ptree), c("A", "B"))
})

test_that("getAncestors returns the sire-then-dam lineage (with repeats)", {
  expect_identical(
    getAncestors("E", ptree),
    c("C", "A", "B", "D", "A", "B")
  )
})

test_that("getAncestors covers the full ancestor set for an ID", {
  expect_setequal(unique(getAncestors("E", ptree)), c("A", "B", "C", "D"))
})

test_that("getAncestors works on a createPedTree() pedigree tree", {
  pt <- createPedTree(nprcgenekeepr::lacy1989Ped)
  expect_setequal(unique(getAncestors("F", pt)), c("A", "B", "D", "E"))
  expect_false("F" %in% getAncestors("F", pt))
})
