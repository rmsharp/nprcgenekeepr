## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #111 coverage backfill: getConfigApiKey() is the soft-lookup of the
## optional apiKey entry in the nprcgenekeepr config file. Its file-present
## paths (a present apiKey, and a present-but-absent apiKey -> "") were never
## exercised directly (only the missing-file path was reached indirectly),
## leaving line 21 (and 23) uncovered. It is @noRd, so reach it with ::: .

test_that("getConfigApiKey returns the apiKey when the config file has one", {
  cfg <- withr::local_tempfile()
  writeLines(c("center = SNPRC", "apiKey = abc123XYZ"), cfg)
  expect_identical(nprcgenekeepr:::getConfigApiKey(cfg), "abc123XYZ")
})

test_that("getConfigApiKey returns '' when the config file lacks an apiKey", {
  cfg <- withr::local_tempfile()
  writeLines("center = SNPRC", cfg)
  expect_identical(nprcgenekeepr:::getConfigApiKey(cfg), "")
})

test_that("getConfigApiKey returns '' for a missing or NULL config file", {
  expect_identical(nprcgenekeepr:::getConfigApiKey(withr::local_tempfile()), "")
  expect_identical(nprcgenekeepr:::getConfigApiKey(NULL), "")
})
