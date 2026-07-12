## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #122 (XARCH-2) Phase 1: normalizeGvReport() is the internal (@noRd)
## seam that maps EITHER genetic-value vocabulary onto reportGV()'s own
## canonical indivMeanKin/gu column names, so a consumer needs to read only
## one vocabulary regardless of which one the caller supplies.
## See docs/planning/issue122-module-contract-plan.md section 4.2.

test_that("normalizeGvReport renames meanKinship/genomeUniqueness to indivMeanKin/gu", {
  gv <- data.frame(
    id = 1:3,
    meanKinship = c(0.1, 0.2, 0.3),
    genomeUniqueness = c(0.9, 0.8, 0.7)
  )
  out <- normalizeGvReport(gv)
  expect_true("indivMeanKin" %in% names(out))
  expect_true("gu" %in% names(out))
  expect_equal(out$indivMeanKin, c(0.1, 0.2, 0.3))
  expect_equal(out$gu, c(0.9, 0.8, 0.7))
})

test_that("normalizeGvReport leaves an already-canonical frame unchanged (idempotent)", {
  gv <- data.frame(
    id = 1:3,
    indivMeanKin = c(0.1, 0.2, 0.3),
    gu = c(0.9, 0.8, 0.7)
  )
  out <- normalizeGvReport(gv)
  expect_identical(out, gv)
})

test_that("normalizeGvReport is a no-op when neither vocabulary is present", {
  gv <- data.frame(id = 1:3, x = c(1, 2, 3))
  out <- normalizeGvReport(gv)
  expect_identical(out, gv)
})

test_that("normalizeGvReport returns NULL unchanged", {
  expect_null(normalizeGvReport(NULL))
})
