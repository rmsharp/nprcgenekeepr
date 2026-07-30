## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# -----------------------------------------------------------------------
# Issue #126: calcKurtosis() is the bias-adjusted Fisher-Pearson EXCESS
# kurtosis coefficient G2 (Joanes & Gill 1998, "Method 2"), G2 = ((n+1)*g2 +
# 6) * (n-1) / ((n-2)*(n-3)), where g2 = m4 / m2^2 - 3 and m2/m4 are the
# 2nd/4th central sample moments. Excess (not raw) kurtosis: a normal
# distribution reads 0, matching every common statistics package's default
# (plan Dragon P4). NA when n <= 3 or the sample has zero variance (m2 == 0,
# all-identical values) -- both degeneracies would otherwise divide by zero.
# -----------------------------------------------------------------------

test_that("calcKurtosis matches a hand-computed value on a known vector", {
  ## x = c(1, 2, 3, 4, 100): mean = 22, m2 = 1522, m4 computed independently
  ## in R; G2 pinned here as the golden value.
  x <- c(1, 2, 3, 4, 100)
  expect_equal(calcKurtosis(x), 4.9868659572, tolerance = 1e-8)
})

test_that("calcKurtosis is NA for n <= 3", {
  expect_true(is.na(calcKurtosis(c(1, 2, 3))))
  expect_true(is.na(calcKurtosis(c(1, 2))))
  expect_true(is.na(calcKurtosis(numeric(0))))
})

test_that("calcKurtosis is NA for a zero-variance (all-identical) vector", {
  expect_true(is.na(calcKurtosis(rep(5, 10))))
})

test_that("calcKurtosis respects na.rm", {
  x <- c(1, 2, 3, 4, 100, NA)
  expect_equal(calcKurtosis(x, na.rm = TRUE), 4.9868659572, tolerance = 1e-8)
  expect_true(is.na(calcKurtosis(x, na.rm = FALSE)))
})

test_that("calcKurtosis is NA on the real bundled genome-uniqueness degeneracy", {
  gu <- nprcgenekeepr::qcPedGvReport$report$gu
  expect_true(all(gu == 0))
  expect_true(is.na(calcKurtosis(gu)))
})

test_that("calcKurtosis matches the plan's worked example on mean kinship", {
  mk <- nprcgenekeepr::qcPedGvReport$report$indivMeanKin
  expect_equal(calcKurtosis(mk), -0.9981580564, tolerance = 1e-6)
})

test_that("calcKurtosis returns EXCESS kurtosis, not raw (Dragon P4)", {
  ## A large, roughly normal sample should read close to 0 (excess), not 3
  ## (raw). rnorm() isn't reproducible without a seed baked into the fixture,
  ## so this uses a deterministic near-normal vector instead: quantiles of a
  ## standard normal at evenly spaced probabilities.
  x <- qnorm(ppoints(200))
  expect_lt(abs(calcKurtosis(x)), 0.5)
})
