#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("convertFromCenter")
library(testthat)
original <- c("y", "yes", "Y", "Yes", "YES",
              "n", "N", "No", "NO", "no",
              "t", "T", "True", "true", "TRUE",
              "f", "F", "false", "False","FALSE",
              NA)
fromCenter <- convertFromCenter(original)
test_that("convertFromCenter makes correct transformations", {
  expect_true(is.logical(fromCenter))
  expect_equal(fromCenter[1], TRUE)
  expect_equal(fromCenter[2], TRUE)
  expect_equal(fromCenter[3], TRUE)
  expect_equal(fromCenter[4], TRUE)
  expect_equal(fromCenter[5], TRUE)
  expect_equal(fromCenter[6], FALSE)
  expect_equal(fromCenter[7], FALSE)
  expect_equal(fromCenter[8], FALSE)
  expect_equal(fromCenter[9], FALSE)
  expect_equal(fromCenter[10], FALSE)
  expect_equal(fromCenter[11], TRUE)
  expect_equal(fromCenter[12], TRUE)
  expect_equal(fromCenter[13], TRUE)
  expect_equal(fromCenter[14], TRUE)
  expect_equal(fromCenter[15], TRUE)
  expect_equal(fromCenter[16], FALSE)
  expect_equal(fromCenter[17], FALSE)
  expect_equal(fromCenter[18], FALSE)
  expect_equal(fromCenter[19], FALSE)
  expect_equal(fromCenter[20], FALSE)
  expect_equal(fromCenter[21], NA)
})
test_that("convertFromCenter detects ambiguous entries", {
  expect_error(convertFromCenter("si"), "fromCenter field has ambiguous values")
})
