#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of mprcgenekeepr
library(testthat)
library(stringi)

set_seed(10L)
pedSix <- mprcgenekeepr::pedSix
changedColsTab <- getChangedColsTab(qcStudbook(pedSix,
  reportChanges = TRUE,
  reportErrors = TRUE
), "test")
test_that("getChangedColsTab creates predictable output", {
  expect_true(stri_detect_fixed(changedColsTab$children[[1L]]$children[[1L]],
    pattern = "egoid to id"
  ))
})
