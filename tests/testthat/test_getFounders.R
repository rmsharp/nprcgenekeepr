## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Lacy (1989) example pedigree: founders A, B, E (both parents unknown).
lacyPed <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G"),
  sire = c(NA, NA, "A", "A", NA, "D", "D"),
  dam = c(NA, NA, "B", "B", NA, "E", "E"),
  stringsAsFactors = FALSE
)

## Only "P" has both parents unknown; Q, R, S have partial or full parentage.
partialPed <- data.frame(
  id = c("P", "Q", "R", "S"),
  sire = c(NA, NA, "P", "P"),
  dam = c(NA, "P", NA, "Q"),
  stringsAsFactors = FALSE
)

test_that("getFounders returns the ids of animals with both parents unknown", {
  expect_identical(getFounders(lacyPed), c("A", "B", "E"))
})

test_that("getFounders excludes partial-parentage animals", {
  expect_identical(getFounders(partialPed), "P")
})

test_that("getFounders preserves id order and is consistent with isFounder", {
  expect_identical(getFounders(lacyPed), lacyPed$id[isFounder(lacyPed)])
})

test_that("getFounders returns every id when all animals are founders", {
  allFounders <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, NA),
    dam = c(NA, NA, NA),
    stringsAsFactors = FALSE
  )
  expect_identical(getFounders(allFounders), c("A", "B", "C"))
})

test_that("getFounders returns character(0) when there are no founders", {
  noFounders <- data.frame(
    id = c("A", "B"),
    sire = c("X", "Y"),
    dam = c("Y", "X"),
    stringsAsFactors = FALSE
  )
  expect_identical(getFounders(noFounders), character(0))
})

test_that("getFounders returns an empty vector for an empty pedigree", {
  emptyPed <- data.frame(
    id = character(0),
    sire = character(0),
    dam = character(0),
    stringsAsFactors = FALSE
  )
  expect_identical(getFounders(emptyPed), character(0))
})
