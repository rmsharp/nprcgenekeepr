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

## Issue #122 (XARCH-2) Phase 1: reportGV()'s own vocabulary (indivMeanKin/gu)
## must also work, not just the renamed meanKinship/genomeUniqueness. Before
## the fix, makeGeneticSummaryTable(reportGV(ped)$report) silently returns an
## all-N/A table with no error or warning.

test_that("makeGeneticSummaryTable accepts reportGV()'s own indivMeanKin/gu vocabulary", {
  ## n = 4 (not 3): kurtosis (issue #126) needs n > 3 to be non-degenerate
  ## (plan Dragon P3) -- n = 3 would legitimately produce "N/A" for Kurtosis
  ## alone, unrelated to what this test verifies (vocabulary acceptance).
  gv <- data.frame(id = 1:4, indivMeanKin = c(.1, .2, .3, .4),
                    gu = c(.9, .8, .7, .6))
  html <- makeGeneticSummaryTable(gv)
  expect_false(grepl("N/A", html, fixed = TRUE))
})

test_that("makeGeneticSummaryTable is vocabulary-agnostic: same values, identical HTML", {
  legacy <- data.frame(
    meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5)
  )
  canonical <- data.frame(
    indivMeanKin = c(0.1, 0.2, 0.3, 0.4, 0.5),
    gu = c(0.9, 0.8, 0.7, 0.6, 0.5)
  )
  expect_identical(makeGeneticSummaryTable(legacy), makeGeneticSummaryTable(canonical))
})

## Issue #126: Skewness/Kurtosis columns (bias-adjusted G1/excess G2,
## Joanes & Gill 1998) added alongside the existing Min/1st Qu./Mean/Median/
## 3rd Qu./Max columns -- golden-master discipline (plan Dragon P5): the
## existing columns above must be unaffected, only gain two new ones.

test_that("makeGeneticSummaryTable's header gains Skewness and Kurtosis columns", {
  gv <- data.frame(
    meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5)
  )
  html <- makeGeneticSummaryTable(gv)
  expect_true(grepl("<th>Skewness</th>", html, fixed = TRUE))
  expect_true(grepl("<th>Kurtosis</th>", html, fixed = TRUE))
})

test_that("makeGeneticSummaryTable reports correct Skewness/Kurtosis values", {
  ## c(0.1, 0.2, 0.3, 0.4, 0.5) is exactly symmetric (5 evenly spaced points):
  ## G1 = 0, G2 (excess) = -1.2 -- computed independently and pinned here.
  gv <- data.frame(
    meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
    genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5)
  )
  html <- makeGeneticSummaryTable(gv)
  expect_true(grepl("0.0000", html, fixed = TRUE))
  expect_true(grepl("-1.2000", html, fixed = TRUE))
})

test_that("makeGeneticSummaryTable renders 'N/A' Skewness/Kurtosis for a zero-variance column", {
  ## Real, non-hypothetical degeneracy: qcPedGvReport$report$gu is uniformly
  ## 0 today (plan Sec.4) -- the m2 == 0 guard must render 'N/A', not crash
  ## or silently produce NaN/Inf in the HTML.
  gv <- data.frame(
    indivMeanKin = c(0.1, 0.2, 0.3, 0.4, 0.5),
    gu = rep(0, 5L)
  )
  html <- makeGeneticSummaryTable(gv)
  expect_true(grepl("N/A", html, fixed = TRUE))
})
