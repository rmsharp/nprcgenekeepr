## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #123 (XARCH-5) Phase 1: assertRequiredColsPresent(availableCols,
# required, where) is the internal (@noRd) explicit setdiff()+stop() validator
# wired at the 3 silent-drop sites (reportGV.R:211, qcStudbook.R:316,
# gvaConvergence.R:161), mirroring the already-tested checkKinshipOverrides.R
# idiom. It is not exported and has no existing call sites yet -- these tests
# exercise it directly.

test_that("assertRequiredColsPresent is silent (invisible NULL) when all required columns are present", {
  expect_error(
    assertRequiredColsPresent(c("id", "sex", "sire"), c("id", "sex"), "test"),
    NA
  )
  expect_null(
    assertRequiredColsPresent(c("id", "sex", "sire"), c("id", "sex"), "test")
  )
})

test_that("assertRequiredColsPresent stops naming a single missing column", {
  expect_error(
    assertRequiredColsPresent(c("id", "sire"), c("id", "sex"), "test"),
    "required column\\(s\\) missing in test: sex"
  )
})

test_that("assertRequiredColsPresent stops naming multiple missing columns", {
  expect_error(
    assertRequiredColsPresent(c("id"), c("id", "sex", "sire"), "test"),
    "required column\\(s\\) missing in test: sex, sire"
  )
})

test_that("assertRequiredColsPresent's missing-column message does not depend on availableCols' order", {
  msg1 <- tryCatch(
    assertRequiredColsPresent(c("sire", "id"), c("id", "sex"), "test"),
    error = function(e) conditionMessage(e)
  )
  msg2 <- tryCatch(
    assertRequiredColsPresent(c("id", "sire"), c("id", "sex"), "test"),
    error = function(e) conditionMessage(e)
  )
  expect_identical(msg1, msg2)
})

test_that("assertRequiredColsPresent names the 'where' argument in its message", {
  expect_error(
    assertRequiredColsPresent(character(0L), c("id"), "reportGV(ped)"),
    "reportGV\\(ped\\)"
  )
})
