#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("calcA")
library(testthat)
data("ped1Alleles")

test_that("calcA forms dataframe with correct calculations", {
  rare <- calcA(ped1Alleles, threshold = 3, byID = FALSE)
  expect_equal(sum(rare[, 1]), 318)
  expect_equal(sum(rare[, 2]), 325)
  expect_equal(sum(rare[, 3]), 313)
  expect_equal(sum(rare[, 4]), 328)
})
