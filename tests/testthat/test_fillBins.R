#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("fillBins")
library(testthat)
library(lubridate)
library(stringi)
set_seed(10)
pedOne <- data.frame(ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
                  `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
                  dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
                  sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
                  birth_date = mdy(
                    paste0(sample(1:12, 8, replace = TRUE), "-",
                           sample(1:28, 8, replace = TRUE), "-",
                           sample(seq(0, 15, by = 3), 8, replace = TRUE) +
                             2000)),
                  stringsAsFactors = FALSE, check.names = FALSE)
pedOne$age <- (mdy("06/01/2018") - as.Date(pedOne$birth)) / dyears(1)
test_that("fillBins adds correct number to each bin", {
  lower_ages <- seq(0, 20, by = 5)
  upper_ages <- NULL
  expect_equal(fillBins(pedOne, lower_ages)$males, c(0, 0, 2, 1, 0))
  expect_equal(fillBins(pedOne, lower_ages)$females, c(2, 2, 0, 1, 0))
})
