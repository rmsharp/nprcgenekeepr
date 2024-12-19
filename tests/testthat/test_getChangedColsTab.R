#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getChangedColsTab")
library(testthat)
library(lubridate)
library(stringi)

set_seed(10)
pedSix <- nprcgenekeepr::pedSix
changedColsTab <- getChangedColsTab(qcStudbook(pedSix, reportChanges = TRUE,
                                               reportErrors = TRUE), "test")
test_that("getChangedColsTab creates predictable output", {
  expect_true(stri_detect_fixed(changedColsTab$children[[1]]$children[[1]],
                                pattern = "egoid to id"))
})
