## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Issue #119 Slice 1: resolveBreedingAge() is the shared internal helper that
## turns the two optional override scalars (minSireAge, minDamAge) plus a
## (species, sex) context into a per-row numeric breeding-age floor. It wraps
## the existing getSpeciesMinBreedingAge() lookup: both overrides NULL -> pure
## species+sex table lookup; a supplied override wins for that sex; absent or
## unknown species falls back to the default (2). Vectorized, keyed per row.
library(testthat)

test_that("resolveBreedingAge looks up species+sex floors when no overrides", {
  expect_equal(resolveBreedingAge("RHESUS", "M"), 4)
  expect_equal(resolveBreedingAge("RHESUS", "F"), 2.5)
  expect_equal(
    resolveBreedingAge(c("RHESUS", "RHESUS"), c("M", "F")),
    c(4, 2.5)
  )
})

test_that("resolveBreedingAge sire override applies to males only", {
  res <- resolveBreedingAge(c("RHESUS", "RHESUS"), c("M", "F"),
    minSireAge = 6
  )
  expect_equal(res, c(6, 2.5))
})

test_that("resolveBreedingAge dam override applies to females only", {
  res <- resolveBreedingAge(c("RHESUS", "RHESUS"), c("M", "F"),
    minDamAge = 5
  )
  expect_equal(res, c(4, 5))
})

test_that("resolveBreedingAge both overrides apply per sex", {
  res <- resolveBreedingAge(c("RHESUS", "RHESUS"), c("M", "F"),
    minSireAge = 6, minDamAge = 5
  )
  expect_equal(res, c(6, 5))
})

test_that("resolveBreedingAge falls back to default for unknown species", {
  expect_equal(resolveBreedingAge(NA, "M"), 2)
  expect_equal(resolveBreedingAge("UNICORN", "F"), 2)
  expect_equal(resolveBreedingAge("", "M"), 2)
})

test_that("resolveBreedingAge honors a non-default fallback value", {
  expect_equal(resolveBreedingAge("UNICORN", "M", default = 3), 3)
})

test_that("resolveBreedingAge is vectorized preserving length and order", {
  species <- c("RHESUS", "BABOON", "UNICORN")
  sex <- c("M", "F", "M")
  res <- resolveBreedingAge(species, sex)
  expect_length(res, 3L)
  ## rhesus M = 4, baboon F = 4, unknown = 2
  expect_equal(res, c(4, 4, 2))
})

test_that("resolveBreedingAge honors an injected breedingTable", {
  tbl <- data.frame(
    species = "DRAGON",
    minMaleBreedingAge = 7, minFemaleBreedingAge = 3,
    stringsAsFactors = FALSE
  )
  expect_equal(resolveBreedingAge("DRAGON", "M", breedingTable = tbl), 7)
  expect_equal(resolveBreedingAge("DRAGON", "F", breedingTable = tbl), 3)
})

test_that("resolveBreedingAge override wins over the injected table", {
  tbl <- data.frame(
    species = "DRAGON",
    minMaleBreedingAge = 7, minFemaleBreedingAge = 3,
    stringsAsFactors = FALSE
  )
  expect_equal(
    resolveBreedingAge("DRAGON", "M", minSireAge = 9, breedingTable = tbl),
    9
  )
})
