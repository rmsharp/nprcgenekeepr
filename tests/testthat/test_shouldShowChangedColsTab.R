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
