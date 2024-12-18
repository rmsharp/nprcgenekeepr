#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("withinIntegerRange")

test_that("withinIntegerRange forces value to integer within range", {
  expect_equal(withinIntegerRange(), 0)
  expect_equal(withinIntegerRange(LETTERS, 0, 10), rep(0, 26))
  expect_equal(withinIntegerRange(2.6, 1, 5), 2)
  expect_equal(withinIntegerRange(2.6, 0, 2), 2)
  expect_equal(withinIntegerRange(c(0, 2.6, -1), 0, 2), c(0, 2, 0))
  expect_equal(withinIntegerRange(c(0, 2.6, -1, NA), 0, 2), c(0, 2, 0, 0))
  expect_equal(withinIntegerRange(c(0, 2.6, -1, NA), 0, 2, na = "max"),
               c(0, 2, 0, 2))
  expect_equal(withinIntegerRange(c(0, 2.6, -1, NA), 0, 2, na = "min"),
               c(0, 2, 0, 0))
  expect_equal(withinIntegerRange(NA, 0, 10, na = "max"), 10)
  expect_equal(withinIntegerRange(, 0, 10, na = "max"), 0)
  expect_equal(withinIntegerRange(NULL, 0, 10, na = "max"), 0)
})
