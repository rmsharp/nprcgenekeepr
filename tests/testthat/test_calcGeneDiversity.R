## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# ---------------------------------------------------------------------------
# Issue #118 Slice 1 (E1): gene diversity retained in the founding gene pool,
# GD = 1 - 1 / (2 * FG), a pure deterministic function of the founder genome
# equivalents (FG) already computed in the reportGV bundle. GD is the expected
# heterozygosity retained (0 = none; -> 1 as FG grows); it is NOT an "Ne count"
# and is over the SAME population as FG (the analysis set), unlike the
# living-breeder demographic effective sizes (E2/E3). No gene drop, no seed.
# ---------------------------------------------------------------------------
test_that("calcGeneDiversity returns the closed-form GD = 1 - 1/(2*FG)", {
  ## exact value at FG = 20: 1 - 1/40 = 0.975
  expect_equal(calcGeneDiversity(20), 0.975)
  ## FG = 1 -> 1 - 1/2 = 0.5
  expect_equal(calcGeneDiversity(1), 0.5)
  ## a non-integer point: FG = 52.75 (the qcPed founder genome equivalents)
  expect_equal(calcGeneDiversity(52.75), 1 - 1 / (2 * 52.75))
})

test_that("calcGeneDiversity floors at 0 for the minimal one-genome pool", {
  ## FG = 0.5 -> 1 - 1/1 = 0 (the smallest meaningful FG; GD = 0 = no diversity)
  expect_equal(calcGeneDiversity(0.5), 0)
})

test_that("calcGeneDiversity is monotone increasing in FG", {
  ## more founder genomes retained -> more diversity retained
  expect_lt(calcGeneDiversity(10), calcGeneDiversity(40))
  expect_lt(calcGeneDiversity(40), calcGeneDiversity(100))
  ## approaches but never reaches 1
  expect_lt(calcGeneDiversity(1e6), 1)
  expect_gt(calcGeneDiversity(1e6), 0.9999)
})

test_that("calcGeneDiversity propagates the FG zero-retention degeneracy", {
  ## calcFEFG()/calcFG() return NA_real_ for FG when a contributing founder is
  ## retained in zero gene-drop iterations; GD must carry that NA through rather
  ## than silently computing on it.
  expect_true(is.na(calcGeneDiversity(NA_real_)))
})

test_that("calcGeneDiversity returns a length-1 numeric scalar", {
  gd <- calcGeneDiversity(20)
  expect_type(gd, "double")
  expect_length(gd, 1L)
})
