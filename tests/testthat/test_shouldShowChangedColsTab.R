## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #111 coverage backfill: shouldShowChangedColsTab() decides whether the
## Changed-Columns tab is shown. Existing tests pass NULL, list(), and populated
## lists, but never a non-NULL non-list value, leaving the is.list() guard
## (line 34) uncovered.

test_that("shouldShowChangedColsTab returns FALSE for non-list, non-NULL input", {
  expect_false(shouldShowChangedColsTab("not a list"))
  expect_false(shouldShowChangedColsTab(42L))
  expect_false(shouldShowChangedColsTab(c(1, 2, 3)))
})

test_that("shouldShowChangedColsTab returns FALSE for NULL and empty list", {
  expect_false(shouldShowChangedColsTab(NULL))
  expect_false(shouldShowChangedColsTab(list()))
})

test_that("shouldShowChangedColsTab returns TRUE when a change field is present", {
  expect_true(shouldShowChangedColsTab(list(caseChange = c(Id = "id"))))
})

## S1020 (BACKLOG.md:168): the tab must open for every kind of rename the
## error list records, and only when summary() has a sentence to put in it.
## getEmptyErrorLst()$changedCols has 13 fields; the check named 12 of them,
## and summary() wrote a sentence for 10.
test_that("shouldShowChangedColsTab opens for each of the 13 kinds of column rename", {
  fields <- names(getEmptyErrorLst()$changedCols)
  expect_length(fields, 13L)
  for (field in fields) {
    changedCols <- getEmptyErrorLst()$changedCols
    changedCols[[field]] <- "oldName to newName"
    expect_true(shouldShowChangedColsTab(changedCols), info = field)
  }
})

test_that("the Changed Columns tab opens exactly when summary() has a sentence for it", {
  for (field in names(getEmptyErrorLst()$changedCols)) {
    errorLst <- getEmptyErrorLst()
    errorLst$changedCols[[field]] <- "oldName to newName"
    hasSentence <- nzchar(trimws(summary(errorLst)$txt))
    expect_identical(shouldShowChangedColsTab(errorLst$changedCols),
                     hasSentence, info = field)
    expect_true(hasSentence, info = field)
  }
  expect_false(nzchar(trimws(summary(getEmptyErrorLst())$txt)))
  expect_false(shouldShowChangedColsTab(getEmptyErrorLst()$changedCols))
})
