## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
data(lacy1989Ped)
ped <- lacy1989Ped
ped$gen <- NULL
test_that("findGeneration labels generations correctly", {
  expect_equal(
    findGeneration(ped$id, ped$sire, ped$dam),
    lacy1989Ped$gen
  )
})

test_that("findGeneration warns when a 2-cycle leaves ids unplaced", {
  # a <-> b mutual cycle: neither can ever be placed, so both stay NA.
  expect_warning(
    findGeneration(c("a", "b"), c("b", "a"), c(NA, NA)),
    regexp = "could not be assigned a generation"
  )
  gen <- suppressWarnings(
    findGeneration(c("a", "b"), c("b", "a"), c(NA, NA))
  )
  expect_true(all(is.na(gen)))
})

test_that("findGeneration warns for a dangling parent and leaves the orphan NA", {
  # 'GHOST' is referenced as a sire but is not itself an ego id.
  expect_warning(
    findGeneration(c("A", "B"), c(NA, "GHOST"), c(NA, NA)),
    regexp = "GHOST"
  )
  gen <- suppressWarnings(
    findGeneration(c("A", "B"), c(NA, "GHOST"), c(NA, NA))
  )
  expect_equal(gen[1], 0L) # A is a founder (both parents NA)
  expect_true(is.na(gen[2])) # B's sire GHOST never resolves
})

test_that("findGeneration emits no warning for a valid self-contained pedigree", {
  # Regression guard: the happy path must never trigger the new diagnostic.
  expect_warning(
    findGeneration(ped$id, ped$sire, ped$dam),
    regexp = NA
  )
})
