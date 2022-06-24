#' Copyright(c) 2017-2022 R. Mark Sharp
# This file is part of nprcgenekeepr
context("makeRoundUp")
library(testthat)
test_that("makeRoundup correctly rounded values based on integer and modulus", {
  int1 <- makeRoundUp(int = 1, modulus = 2)
  expect_equal(int1, 2)
  int1 <- makeRoundUp(int = 1, modulus = 3)
  expect_equal(int1, 3)
  int1 <- makeRoundUp(int = 3, modulus = 2)
  expect_equal(int1, 4)
  int1 <- makeRoundUp(int = 16, modulus = 5)
  expect_equal(int1, 20)
})
