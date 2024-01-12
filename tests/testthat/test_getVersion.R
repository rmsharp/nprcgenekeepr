#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getVersion")
library(testthat)
library(stringi)
test_that("getVersion returns a version and date", {
  version <- suppressWarnings(getVersion())
  expect_true(stri_detect_regex(version, # version
                                pattern = "^[0-9]{1,2}([.][0-9]{1,2})"))
  expect_true(stri_detect_regex(version, pattern = "[0-9]{8}")) # date
})
test_that("getVersion returns a version and date with date boolean set TRUE", {
  version <- suppressWarnings(getVersion())
  expect_true(stri_detect_regex(version, # version
                                pattern = "^[0-9]{1,2}([.][0-9]{1,2})"))
  expect_true(stri_detect_regex(version, pattern = "[0-9]{8}")) # date
})
test_that("getVersion returns a version with date boolean set FALSE", {
  version <- suppressWarnings(getVersion(date = FALSE))
  expect_true(stri_detect_regex(version, # version
                                pattern = "^[0-9]{1,2}([.][0-9]{1,2})"))
  expect_false(stri_detect_regex(version, pattern = "[0-9]{8}")) # date
})
test_that("getVersion returns a warning", {
  expect_warning(getVersion())
  expect_warning(getVersion(date = TRUE))
  expect_warning(getVersion(date = FALSE))
})
