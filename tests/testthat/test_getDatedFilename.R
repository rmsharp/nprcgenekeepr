#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getDatedFilename")
library(testthat)
library(lubridate)
library(stringi)
dateStamp <- stri_replace_all_fixed(
  stri_replace_all_fixed(as.character(now()), " ", "_"), ":", "_")
test_that("getDatedFilename form correctly dated file name", {
  expect_equal(stri_sub(getDatedFilename("testName"), 1, 13),
               stri_sub(stri_c(dateStamp, "_", "testName"), 1, 13))
  expect_equal(stri_sub(getDatedFilename("testName"), 21), "testName")
})
