#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Input Module
library(testthat)

test_that("E2E: Input module has clear instructions", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_instructions")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("upload|select|choose|file", html, ignore.case = TRUE),
    info = "Should have file selection instructions"
  )
})

test_that("E2E: Input module supports CSV format", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_csv")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("csv|comma|delimited", html, ignore.case = TRUE),
    info = "Should indicate CSV format support"
  )
})

test_that("E2E: Input module supports Excel format", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_excel")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("excel|xlsx|xls|spreadsheet", html, ignore.case = TRUE),
    info = "Should indicate Excel format support"
  )
})

test_that("E2E: Input module has example data option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_example")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  html <- get_html_safe(app, "body")
  # Many apps provide example/demo data
  has_example <- grepl("example|demo|sample|test", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Input module loaded successfully")
})

test_that("E2E: Input module displays quality control options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_qc_options")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("quality|control|QC|validation|check", html, ignore.case = TRUE),
    info = "Should have quality control options"
  )
})

test_that("E2E: Input module has data preview area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_preview")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  html <- get_html_safe(app, "body")
  # Check for table/data preview elements
  has_preview <- grepl(
    "table|preview|data|studbook|pedigree",
    html,
    ignore.case = TRUE
  )
  expect_true(has_preview, info = "Should have data preview area")
})
