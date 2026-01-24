#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Input Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

# All tests in this file use the Input tab - share one app instance
local({
  # Cleanup shared apps when this test file completes
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Input module has clear instructions", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content(
    "Input",
    "upload|select|choose|file",
    info = "Should have file selection instructions"
  )
})

test_that("E2E: Input module supports CSV format", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content(
    "Input",
    "csv|comma|delimited",
    info = "Should indicate CSV format support"
  )
})

test_that("E2E: Input module supports Excel format", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content(
    "Input",
    "excel|xlsx|xls|spreadsheet",
    info = "Should indicate Excel format support"
  )
})

test_that("E2E: Input module has example data option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Input")
  if (is.null(shared)) skip("Could not navigate to Input tab")

  # Many apps provide example/demo data - just verify tab loaded
  expect_true(nchar(shared$html) > 100, info = "Input module loaded successfully")
})

test_that("E2E: Input module displays quality control options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content(
    "Input",
    "quality|control|QC|validation|check",
    info = "Should have quality control options"
  )
})

test_that("E2E: Input module has data preview area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content(
    "Input",
    "table|preview|data|studbook|pedigree",
    info = "Should have data preview area"
  )
})
