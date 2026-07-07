## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #111 coverage backfill: runQcStudbook() wraps qcStudbook() in two
## tryCatch passes. qcStudbook signals detected data problems by RETURNING them
## inside errorLst, not by raising R conditions, so with every real fixture the
## warning/error handlers never fire and the synthetic "Data Processing Error"
## branch is skipped -- lines 92-97, 100-105, 125-134 (first pass) and 178-183,
## 186-191 (second pass) were uncovered. Force those conditions by mocking
## qcStudbook via testthat::local_mocked_bindings (the pattern already used
## across the modInput tests).

pedGood <- nprcgenekeepr::pedGood

test_that("runQcStudbook reports a first-pass error as a Data Processing Error", {
  local_mocked_bindings(qcStudbook = function(...) stop("boom"))
  res <- runQcStudbook(pedGood)
  expect_true(res$qcResult$hasErrors)
  expect_null(res$cleaned)
  expect_true(any(res$qcResult$errors$Error == "Data Processing Error"))
  expect_true(any(grepl("boom", res$qcResult$errors$Details, fixed = TRUE)))
})

test_that("runQcStudbook survives a first-pass warning and a second-pass warning", {
  local_mocked_bindings(qcStudbook = function(...) {
    warning("just a warning")
    getEmptyErrorLst()
  })
  res <- runQcStudbook(pedGood)
  ## First-pass warning handler returns an empty errorLst (no errors); the
  ## second pass also warns, so the cleaned pedigree comes back NULL.
  expect_false(res$qcResult$hasErrors)
  expect_null(res$cleaned)
})

test_that("runQcStudbook handles a clean first pass then a second-pass error", {
  local_mocked_bindings(
    qcStudbook = function(ped, ..., reportErrors) {
      if (reportErrors) getEmptyErrorLst() else stop("second pass failed")
    }
  )
  res <- runQcStudbook(pedGood)
  expect_false(res$qcResult$hasErrors)
  expect_null(res$cleaned)
})

## Issue #119 Slice 1: runQcStudbook threads the new sex-specific
## breeding-age params through to qcStudbook; minParentAge stays a deprecated
## alias whose warning is emitted at runQcStudbook's own boundary (not
## swallowed by its internal warning-catching tryCatch passes).
test_that("runQcStudbook accepts minSireAge/minDamAge (issue #119)", {
  resNew <- runQcStudbook(pedGood, minSireAge = 2.0, minDamAge = 2.0)
  resOld <- suppressWarnings(runQcStudbook(pedGood, minParentAge = 2.0))
  expect_identical(resNew$cleaned, resOld$cleaned)
  expect_false(resNew$qcResult$hasErrors)
})

test_that("runQcStudbook minParentAge alias emits a deprecation warning", {
  lifecycle::expect_deprecated(
    runQcStudbook(pedGood, minParentAge = 2.0)
  )
})
