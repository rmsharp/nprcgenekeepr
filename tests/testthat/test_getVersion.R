#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getVersion")
library(testthat)
library(stringi)
test_that("getVersion returns a version", {
  version1 <- getVersion()
  expect_true(stri_detect_regex(version1, # version
                                pattern = "^[0-9]{1,2}([.][0-9]{1,2})"))
  expect_true(stri_detect_fixed(version1, pattern = "("))
  expect_true(stri_detect_regex(version1, pattern = "[0-9]{4}")) # date
  version2 <- getVersion(date = FALSE)
  expect_true(stri_detect_regex(version2, # version
                                pattern = "^[0-9]{1,2}([.][0-9]{1,2})"))
  expect_false(stri_detect_regex(version2, pattern = "[0-9]{4}")) # date
  expect_false(stri_detect_fixed(version2, pattern = "("))
})
