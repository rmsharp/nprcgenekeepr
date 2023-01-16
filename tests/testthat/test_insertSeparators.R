#' Copyright(c) 2017-2023 R. Mark Sharp
# This file is part of nprcgenekeepr
context("insertSeparators")
library(testthat)
test_that(
  "insert separators at the right time and in the correct way", {
    expect_equal(nprcgenekeepr:::insertSeparators(c("19991002",
                                                    "20100228"))[[1]],
                 "1999-10-02")
    expect_equal(nprcgenekeepr:::insertSeparators(c("19991002",
                                                    "20100228"))[[2]],
                 "2010-02-28")
    expect_equal(nprcgenekeepr:::insertSeparators(c("1999/10/02",
                                                    "2010/02/28"))[[2]],
                 "2010/02/28")
})
