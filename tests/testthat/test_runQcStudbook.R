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

## S933: the Input tab's "Animals with no birth date" warning (BACKLOG.md,
## owner ruled S932 and S933). runQcStudbook() adds the row to
## qcResult$warnings after its second pass, only when reportChanges is TRUE
## (the argument already means "put notices in the result", and the Input tab
## asks for TRUE), and never when errors exist or the second pass fails,
## because then there is no cleaned pedigree to count. The row never makes
## hasErrors TRUE.
noBirthWarning <- "Animals with no birth date"

## pedGood's birth column is named birth_date; blank the first animal's.
pedFirstBirthBlank <- function(ped) {
  ped$birth_date[1L] <- NA
  ped
}

test_that("runQcStudbook adds the no-birth-date warning when reportChanges is TRUE", {
  res <- runQcStudbook(pedFirstBirthBlank(pedGood), reportChanges = TRUE)
  expect_false(res$qcResult$hasErrors)
  expect_identical(nrow(res$qcResult$errors), 0L)
  expect_false(is.null(res$cleaned))
  expect_identical(res$qcResult$warnings$Warning, noBirthWarning)
  expect_match(
    res$qcResult$warnings$Details,
    "^1 of 8 animals has no birth date, so their age is unknown\\."
  )
})

test_that("runQcStudbook leaves the no-birth-date warning out unless reportChanges is TRUE", {
  ped <- pedFirstBirthBlank(pedGood)
  resDefault <- runQcStudbook(ped)
  ## The animal does lack a birth date; only the argument keeps the row out.
  expect_identical(sum(is.na(resDefault$cleaned$birth)), 1L)
  expect_identical(nrow(resDefault$qcResult$warnings), 0L)
  resFalse <- runQcStudbook(ped, reportChanges = FALSE)
  expect_identical(nrow(resFalse$qcResult$warnings), 0L)
})

test_that("runQcStudbook adds no no-birth-date warning when every animal has a birth date", {
  res <- runQcStudbook(pedGood, reportChanges = TRUE)
  expect_identical(sum(is.na(res$cleaned$birth)), 0L)
  expect_identical(nrow(res$qcResult$warnings), 0L)
})

test_that("runQcStudbook adds no no-birth-date warning when there are errors", {
  ped <- pedFirstBirthBlank(nprcgenekeepr::pedFemaleSireMaleDam)
  res <- runQcStudbook(ped, reportChanges = TRUE)
  expect_true(res$qcResult$hasErrors)
  expect_null(res$cleaned)
  expect_false(noBirthWarning %in% res$qcResult$warnings$Warning)
})

test_that("runQcStudbook adds no no-birth-date warning when the second pass fails", {
  local_mocked_bindings(
    qcStudbook = function(ped, ..., reportErrors) {
      if (reportErrors) getEmptyErrorLst() else stop("second pass failed")
    }
  )
  res <- runQcStudbook(pedFirstBirthBlank(pedGood), reportChanges = TRUE)
  expect_null(res$cleaned)
  expect_identical(nrow(res$qcResult$warnings), 0L)
})

test_that("runQcStudbook puts the no-birth-date warning after a column-rename warning", {
  ped <- data.frame(
    EGO_ID = c("A", "B", "C"),
    SIRE_ID = c(NA, NA, "A"),
    DAM_ID = c(NA, NA, "B"),
    SEX = c("M", "F", "F"),
    BIRTH_DATE = as.Date(c(NA, "2010-01-01", "2015-01-01")),
    stringsAsFactors = FALSE
  )
  res <- runQcStudbook(ped, minSireAge = 2.0, minDamAge = 2.0,
                       reportChanges = TRUE)
  expect_false(res$qcResult$hasErrors)
  expect_identical(res$qcResult$warnings$Warning,
                   c("Column name case changed", noBirthWarning))
})
