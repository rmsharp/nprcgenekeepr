#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getErrorTab")
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
errorTab <- getErrorTab(qcStudbook(pedOne, reportChanges = TRUE,
                                   reportErrors = TRUE), "test")
test_that("getErrorTab creates predictable output", {
  expect_true(stri_detect_fixed(errorTab$children[[1]]$children[[1]],
                                pattern = "egoid to id"))
})
