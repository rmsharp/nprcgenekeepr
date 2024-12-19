#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
context("meanKinship")
library(testthat)
set_seed(10)
samp <- c(0, 0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625)
kmat <- sample(samp, 25, replace = TRUE)
kmat <- matrix(kmat, nrow = 5)

test_that("meanKinship averages column correctly", {
  expect_equal(kmat[[1]], mean(kmat[[1]]))
  expect_equal(kmat[[2]], mean(kmat[[2]]))
  expect_equal(kmat[[5]], mean(kmat[[5]]))
})
