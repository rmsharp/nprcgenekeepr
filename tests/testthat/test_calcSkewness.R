## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# -----------------------------------------------------------------------
# Issue #126: calcSkewness() is the bias-adjusted Fisher-Pearson standardized
# skewness coefficient G1 (Joanes & Gill 1998, "Method 2"), G1 = g1 *
# sqrt(n*(n-1)) / (n-2), where g1 = m3 / m2^1.5 and m2/m3 are the 2nd/3rd
# central sample moments. NA when n <= 2 or the sample has zero variance
# (m2 == 0, all-identical values) -- both degeneracies would otherwise divide
# by zero.
# -----------------------------------------------------------------------

test_that("calcSkewness matches a hand-computed value on a known vector", {
  ## x = c(1, 2, 3, 4, 100): mean = 22, m2 = 1522, m3 = 88920.
  ## g1 = m3 / m2^1.5; G1 = g1 * sqrt(5*4) / 3 -- computed independently in R
  ## and pinned here as the golden value.
  x <- c(1, 2, 3, 4, 100)
  expect_equal(calcSkewness(x), 2.2323959116, tolerance = 1e-8)
})

test_that("calcSkewness is NA for n <= 2", {
  expect_true(is.na(calcSkewness(c(1, 2))))
  expect_true(is.na(calcSkewness(numeric(0))))
  expect_true(is.na(calcSkewness(5)))
})

test_that("calcSkewness is NA for a zero-variance (all-identical) vector", {
  ## Real, non-hypothetical degeneracy shape: qcPedGvReport$report$gu is
  ## uniformly 0 today (plan Sec.4) -- see the bundled-data test below.
  expect_true(is.na(calcSkewness(rep(5, 10))))
})

test_that("calcSkewness respects na.rm", {
  x <- c(1, 2, 3, 4, 100, NA)
  expect_equal(calcSkewness(x, na.rm = TRUE), 2.2323959116, tolerance = 1e-8)
  expect_true(is.na(calcSkewness(x, na.rm = FALSE)))
})

test_that("calcSkewness is NA on the real bundled genome-uniqueness degeneracy", {
  ## qcPedGvReport$report$gu is uniformly 0 -- the m2 == 0 guard fires on
  ## shipped data, not only a contrived fixture (plan Sec.4, Dragon P2).
  gu <- nprcgenekeepr::qcPedGvReport$report$gu
  expect_true(all(gu == 0))
  expect_true(is.na(calcSkewness(gu)))
})

test_that("calcSkewness matches the plan's worked example on mean kinship", {
  mk <- nprcgenekeepr::qcPedGvReport$report$indivMeanKin
  expect_equal(calcSkewness(mk), 0.3756144701, tolerance = 1e-6)
})
