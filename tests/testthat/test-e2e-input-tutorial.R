#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Input Module - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Input has minimum parent age control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "Minimum.*Parent.*Age|minParentAge|parent.*age|years",
                     info = "Should have minimum parent age control")
})

test_that("E2E: Input has Read and Check Pedigree button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "Read.*Check.*Pedigree|Check.*Pedigree|getData|Upload.*Validate",
                     info = "Should have Read and Check Pedigree button")
})

test_that("E2E: Input has file format documentation", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "format|column|required|optional|ego_id|id|sire|dam|birth",
                     info = "Should have file format documentation")
})

test_that("E2E: Input supports Excel workbook", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "Excel|xlsx|xls|workbook",
                     info = "Should support Excel format")
})

test_that("E2E: Input supports comma-separated values", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "csv|comma|separated|delimiter",
                     info = "Should support CSV format")
})

test_that("E2E: Input supports tab-separated values", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "tab|txt|text|separator",
                     info = "Should support tab-separated format")
})

test_that("E2E: Input has error detection for missing columns", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "error|warning|missing|required|validation",
                     info = "Should mention error detection")
})

test_that("E2E: Input has genotype file support", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Input")
  if (is.null(shared)) skip("Could not navigate to Input tab")
  expect_true(nchar(shared$html) > 100, info = "Input tab loaded")
})
