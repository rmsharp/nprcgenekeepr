#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("get_elapsed_time_str")
start_time <- proc.time()
Sys.sleep(1)
elapsed_time <- get_elapsed_time_str(start_time)

test_that("get_elapsed_time_str gets time string diff back", {
  expect_identical(elapsed_time, "1 seconds.")
})
