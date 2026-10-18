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

## S1012 (docs-audit part 2 CI1): a commented-out apiKey line is not a key. The
## shipped example config documents the key as a commented line, and
## getConfigApiKey() returned its placeholder text as a live key.

test_that("getConfigApiKey returns '' for the shipped example config", {
  example_cfg <- system.file("extdata", "examples",
                             "example_nprcgenekeepr_config",
                             package = "nprcgenekeepr")
  expect_true(nzchar(example_cfg))
  expect_identical(nprcgenekeepr:::getConfigApiKey(example_cfg), "")
})

test_that("getConfigApiKey ignores a commented apiKey before the real one", {
  cfg <- withr::local_tempfile()
  writeLines(c("# apiKey = \"placeholder\"", "center = SNPRC",
               "apiKey = realKey"), cfg)
  expect_identical(nprcgenekeepr:::getConfigApiKey(cfg), "realKey")
})

test_that("getConfigApiKey ignores an indented commented apiKey", {
  cfg <- withr::local_tempfile()
  writeLines(c("center = SNPRC", "   # apiKey = \"indented\""), cfg)
  expect_identical(nprcgenekeepr:::getConfigApiKey(cfg), "")
})

test_that("getConfigApiKey keeps the real apiKey when a commented one follows", {
  cfg <- withr::local_tempfile()
  writeLines(c("center = SNPRC", "apiKey = realKey",
               "# apiKey = \"placeholder\""), cfg)
  expect_identical(nprcgenekeepr:::getConfigApiKey(cfg), "realKey")
})

test_that("getConfigApiKey reads an apiKey line that ends in a comment", {
  cfg <- withr::local_tempfile()
  writeLines(c("center = SNPRC", "apiKey = realKey # from the LabKey site"),
             cfg)
  expect_identical(nprcgenekeepr:::getConfigApiKey(cfg), "realKey")
})
