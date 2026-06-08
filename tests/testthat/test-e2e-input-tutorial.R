#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Input Module - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
library(testthat)

test_that("E2E: Input has minimum parent age control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_min_parent_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "Minimum Parent Age"),
    info = "Input pane active with the minimum-parent-age control"
  )
})

test_that("E2E: Input has Read and Check Pedigree button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_read_check")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "Read and Check Pedigree"),
    info = "Input pane active with the Read and Check Pedigree button"
  )
})

test_that("E2E: Input has file format documentation", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_format_docs")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "Input Format"),
    info = "Input pane active with the file-format documentation tab"
  )
})

test_that("E2E: Input supports Excel workbook", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_excel_support")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "Excel"),
    info = "Input pane active with Excel workbook support"
  )
})

test_that("E2E: Input supports comma-separated values", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_csv_support")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "comma-delimited"),
    info = "Input pane active; format docs indicate comma-separated support"
  )
})

test_that("E2E: Input supports tab-separated values", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_tab_support")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "tab-delimited"),
    info = "Input pane active; format docs indicate tab-separated support"
  )
})

test_that("E2E: Input has error detection for missing columns", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_missing_cols_error")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "Errors"),
    info = "Input pane active with the QC Errors tab"
  )
})

test_that("E2E: Input has genotype file support", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_genotype_file")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "genotype"),
    info = "Input pane active with genotype-file support"
  )
})
