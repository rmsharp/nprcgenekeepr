## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## S1012 REFACTOR: readConfigLines() is the one place a configuration file's
## full-line comments are dropped; getConfigApiKey(), getOptionalConfigToken()
## and getSiteInfo() all read through it. It is @noRd, so reach it with ::: .

test_that("readConfigLines drops full-line comments, indented or not", {
  cfg <- withr::local_tempfile()
  writeLines(c("# header", "center = SNPRC", "   # indented", "\t# tab",
               "baseUrl = http://x"), cfg)
  expect_identical(nprcgenekeepr:::readConfigLines(cfg),
                   c("center = SNPRC", "baseUrl = http://x"))
})

test_that("readConfigLines keeps a line that ends in a comment and blank lines", {
  cfg <- withr::local_tempfile()
  writeLines(c("apiKey = k # note", "", "center = SNPRC"), cfg)
  expect_identical(nprcgenekeepr:::readConfigLines(cfg),
                   c("apiKey = k # note", "", "center = SNPRC"))
})

test_that("readConfigLines returns no lines for a comments-only or empty file", {
  cfg <- withr::local_tempfile()
  writeLines(c("# a", "  # b"), cfg)
  expect_identical(nprcgenekeepr:::readConfigLines(cfg), character(0))
  writeLines(character(0), cfg)
  expect_identical(nprcgenekeepr:::readConfigLines(cfg), character(0))
})
