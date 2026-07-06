## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #111 coverage backfill: makeGeneticSummaryTable() renders an HTML
## summary-stats table. Existing tests always pass a full data.frame with both
## meanKinship and genomeUniqueness columns and >0 rows, leaving the NULL/empty
## placeholder (line 29), the missing-column NA fills (lines 37, 45), and the
## fmt() "N/A" branch (line 50) uncovered.

test_that("makeGeneticSummaryTable returns a placeholder for NULL or empty input", {
  expect_match(makeGeneticSummaryTable(NULL), "No genetic value data")
  expect_match(makeGeneticSummaryTable(data.frame()), "No genetic value data")
})

test_that("makeGeneticSummaryTable fills 'N/A' when the value columns are absent", {
  ## A non-empty frame lacking meanKinship and genomeUniqueness drives the
  ## rep(NA, 6L) fills (lines 37, 45) and fmt()'s NA -> "N/A" branch (line 50).
  html <- makeGeneticSummaryTable(data.frame(x = 1:3))
  expect_true(grepl("N/A", html, fixed = TRUE))
  expect_true(grepl("Mean Kinship", html, fixed = TRUE))
  expect_true(grepl("Genome Uniqueness", html, fixed = TRUE))
})

test_that("makeGeneticSummaryTable formats real statistics without 'N/A'", {
  gv <- data.frame(
    meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5)
  )
  html <- makeGeneticSummaryTable(gv)
  expect_false(grepl("N/A", html, fixed = TRUE))
  expect_true(grepl("0.3000", html, fixed = TRUE))
})
