#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("calcAge")
library(testthat)
suppressMessages(library(lubridate))
set_seed(10)
exit <- mdy(paste0(sample(1:12, 10, replace = TRUE), "-",
                    sample(1:28, 10, replace = TRUE), "-",
                    sample(seq(0, 15, by = 3), 10, replace = TRUE) + 2000))
birth <- exit - days(sample(0:7500, size = 10, replace = TRUE))
exit[c(2, 4)] <- NA
todays_age <- round((as.double(Sys.Date() - birth[c(2, 4)]) / 365.25), 1)
ages <- calcAge(birth, exit)
test_that("calcAge calculates ages correctly", {
  expect_equal(ages[c(2, 4)], todays_age)
  expect_equal(ages[c(1, 3, 5:10)], c(11.0, 3.5, 8.7, 15.4, 16.9, 19.6, 14.1,
                                      10.3))
})
test_that("calcAge returns empty vector if empty vector provided", {
  emptyAges <- calcAge(as.Date(numeric(0), origin = "1-1-1970"), Date(0))
  expect_equal(emptyAges, as.Date(numeric(0), origin = "1-1-1970"))
})
