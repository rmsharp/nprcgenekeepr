#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("convertAncestry")
library(testthat)
original <- c("china", "india", "hybridized", NA, "human", "gorilla")
ancestry <- convertAncestry(original)
test_that("convertAncestry makes correct transformations", {
  expect_true(is.factor(ancestry))
  ancestry <- as.character(ancestry)
  expect_equal(ancestry[1], "CHINESE")
  expect_equal(ancestry[2], "INDIAN")
  expect_equal(ancestry[3], "HYBRID")
  expect_equal(ancestry[4], "UNKNOWN")
  expect_equal(ancestry[5], "OTHER")
  expect_equal(ancestry[6], "OTHER")
})
