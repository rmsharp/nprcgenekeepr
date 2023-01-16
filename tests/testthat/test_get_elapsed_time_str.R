#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("get_elapsed_time_str")
library(testthat)
library(stringi)
start_time <- proc.time()
Sys.sleep(1)
elapsed_time <- get_elapsed_time_str(start_time)

test_that("get_elapsed_time_str gets time string diff back", {
  expect_equal(elapsed_time, "1 seconds.")
})
