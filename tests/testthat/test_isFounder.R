## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Lacy (1989) example pedigree: founders A, B, E (both parents unknown);
## C, D, F, G are descendants.
lacyPed <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G"),
  sire = c(NA, NA, "A", "A", NA, "D", "D"),
  dam = c(NA, NA, "B", "B", NA, "E", "E"),
  stringsAsFactors = FALSE
)

## Pedigree exercising partial parentage: only "P" is a founder.
##   P: both parents unknown    -> founder
##   Q: dam known, sire unknown -> NOT a founder (partial parentage)
##   R: sire known, dam unknown -> NOT a founder (partial parentage)
##   S: both parents known      -> NOT a founder
partialPed <- data.frame(
  id = c("P", "Q", "R", "S"),
  sire = c(NA, NA, "P", "P"),
  dam = c(NA, "P", NA, "Q"),
  stringsAsFactors = FALSE
)

test_that("isFounder flags only animals with BOTH parents unknown", {
  expect_identical(
    isFounder(lacyPed),
    c(TRUE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE)
  )
})

test_that("isFounder treats partial parentage as NOT a founder", {
  expect_identical(
    isFounder(partialPed),
    c(TRUE, FALSE, FALSE, FALSE)
  )
})

test_that("isFounder returns all TRUE when every animal is a founder", {
  allFounders <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, NA),
    dam = c(NA, NA, NA),
    stringsAsFactors = FALSE
  )
  expect_identical(isFounder(allFounders), c(TRUE, TRUE, TRUE))
})

test_that("isFounder returns all FALSE when no animal is a founder", {
  noFounders <- data.frame(
    id = c("A", "B"),
    sire = c("X", "Y"),
    dam = c("Y", "X"),
    stringsAsFactors = FALSE
  )
  expect_identical(isFounder(noFounders), c(FALSE, FALSE))
})

test_that("isFounder returns logical(0) for an empty pedigree", {
  emptyPed <- data.frame(
    id = character(0),
    sire = character(0),
    dam = character(0),
    stringsAsFactors = FALSE
  )
  expect_identical(isFounder(emptyPed), logical(0))
})

test_that("isFounder returns a non-NA logical vector of length nrow(ped)", {
  mask <- isFounder(lacyPed)
  expect_type(mask, "logical")
  expect_length(mask, nrow(lacyPed))
  expect_false(anyNA(mask))
})
