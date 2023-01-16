#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getOffspring")
library(testthat)
data("smallPed")
test_that("getOffspring returns the correct IDs", {
  expect_equal(getOffspring(smallPed, ids = c("A", "B")),
               c("C", "D", "H", "I", "M"))
  expect_equal(getOffspring(smallPed, ids = c("M")),
               c("P"))
  expect_equal(getOffspring(smallPed, ids = c("Q")),
               c("A"))
})
