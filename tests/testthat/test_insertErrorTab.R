#' Copyright(c) 2017-2023 R. Mark Sharp
# This file is part of nprcgenekeepr
context("insertErrorTab")
library(testthat)
library(lubridate)
library(stringi)

set_seed(10)
pedOne <- data.frame(
  ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
  dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
  birth_date = mdy(paste0(sample(1:12, 8, replace = TRUE), "-",
                          sample(1:28, 8, replace = TRUE), "-",
                          sample(seq(0, 15, by = 3), 8, replace = TRUE) +
                            2000)),
  stringsAsFactors = FALSE, check.names = FALSE)
errorLst <- qcStudbook(pedOne, reportErrors = TRUE)
test_that("insertErrorTab forms a character vector", {
  expect_true(inherits(insertErrorTab(errorLst, "test_file"), "character"))
})
test_that("insertErrorTab provides expected output", {
  expect_equal(stri_sub(insertErrorTab(errorLst, "test_file"), 1, 5), "<h3>E")
  expect_true(stri_detect_fixed(
    insertErrorTab(errorLst, "test_file"),
    pattern = stri_c("Error: The animal listed as a sire and also listed as ",
                     "a female is: s1.")))
  expect_true(stri_detect_fixed(
    insertErrorTab(errorLst, "test_file"),
    pattern = stri_c("Error: The animal listed as a dam and also listed as ",
                     "a male is: d1.")))
})
