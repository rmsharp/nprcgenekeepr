#' Copyright(c) 2017-2020 R. Mark Sharp
# This file is part of nprcgenekeepr
context("removeEarlyDates")
library(testthat)

dates <- structure(c(12361, 14400, 15413, NA, 11189, NA, 13224, 10971, -432000,
                     + 13262), class = "Date")
result <- structure(c(12361, 14400, 15413, NA, 11189, NA, 13224, 10971, NA,
                      + 13262), class = "Date")
test_that("removeEarlyDates changes early dates to NA", {
  expect_equal(removeEarlyDates(dates, firstYear = 1000), result)
})
