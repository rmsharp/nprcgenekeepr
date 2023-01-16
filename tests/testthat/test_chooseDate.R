#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("chooseDate")
library(testthat)
library(lubridate)
set_seed(10)
someDates <- mdy(paste0(sample(1:12, 10, replace = TRUE), "-",
                    sample(1:28, 10, replace = TRUE), "-",
                    sample(seq(0, 15, by = 3), 10, replace = TRUE) + 2000))
test_that("chooseDate picks the correct date", {
  expect_equal(chooseDate(someDates[1], NA, earlier = TRUE),
             someDates[1])
  expect_equal(chooseDate(NA, someDates[2], earlier = TRUE),
               someDates[2])
  expect_equal(chooseDate(someDates[1], someDates[2], earlier = TRUE),
               someDates[2])
  expect_equal(chooseDate(someDates[1], someDates[2], earlier = FALSE),
               someDates[1])
  expect_equal(chooseDate(someDates[2], someDates[1], earlier = TRUE),
               someDates[2])
  expect_equal(chooseDate(someDates[2], someDates[1], earlier = FALSE),
               someDates[1])
  expect_equal(chooseDate(someDates[2], someDates[2], earlier = TRUE),
               someDates[2])
})
