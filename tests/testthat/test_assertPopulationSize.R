## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# S924 (BACKLOG item found S923): assertPopulationSize(n, where) is the
# internal (@noRd) check that stops reportGV() and gvaConvergence() before any
# calculation when the population of interest has fewer than 2 animals. It
# mirrors assertRequiredColsPresent(): a stop() with call. = FALSE, and an
# invisible NULL when nothing is wrong. Every expect_error() here carries a
# message pattern: a bare expect_error() would pass while the function does
# not exist.

test_that("assertPopulationSize stops for one animal, with the whole message", {
  expect_error(
    assertPopulationSize(1L, "reportGV(ped)"),
    paste0(
      "^nprcgenekeepr: reportGV\\(ped\\) needs at least 2 animals in the ",
      "population; the population has 1\\.$"
    )
  )
})

test_that("assertPopulationSize stops for no animals and names the count", {
  expect_error(
    assertPopulationSize(0L, "reportGV(ped)"),
    "needs at least 2 animals in the population; the population has 0\\."
  )
})

test_that("assertPopulationSize names the function it was called for", {
  expect_error(
    assertPopulationSize(1L, "reportGV(ped)"),
    "reportGV\\(ped\\) needs at least 2 animals"
  )
  expect_error(
    assertPopulationSize(1L, "gvaConvergence(ped)"),
    "gvaConvergence\\(ped\\) needs at least 2 animals"
  )
})

test_that("assertPopulationSize is silent (invisible NULL) for two or more animals", {
  expect_error(assertPopulationSize(2L, "test"), NA)
  expect_null(assertPopulationSize(2L, "test"))
  expect_null(assertPopulationSize(327L, "test"))
})
