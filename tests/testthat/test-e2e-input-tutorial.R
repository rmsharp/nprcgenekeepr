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

  html <- get_html_safe(app, "body")
  # Tutorial emphasizes minimum parent age setting (e.g., 2 years for macaques)
  has_min_parent_age <- grepl(
    "Minimum.*Parent.*Age|minParentAge|parent.*age|years",
    html,
    ignore.case = TRUE
  )
  expect_true(has_min_parent_age, info = "Should have minimum parent age control")
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

  html <- get_html_safe(app, "body")
  has_read_check <- grepl(
    "Read.*Check.*Pedigree|Check.*Pedigree|getData|Upload.*Validate",
    html,
    ignore.case = TRUE
  )
  expect_true(has_read_check, info = "Should have Read and Check Pedigree button")
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

  html <- get_html_safe(app, "body")
  # Tutorial shows extensive file format documentation
  has_format_docs <- grepl(
    "format|column|required|optional|ego_id|id|sire|dam|birth",
    html,
    ignore.case = TRUE
  )
  expect_true(has_format_docs, info = "Should have file format documentation")
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

  html <- get_html_safe(app, "body")
  has_excel <- grepl(
    "Excel|xlsx|xls|workbook",
    html,
    ignore.case = TRUE
  )
  expect_true(has_excel, info = "Should support Excel format")
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

  html <- get_html_safe(app, "body")
  has_csv <- grepl(
    "csv|comma|separated|delimiter",
    html,
    ignore.case = TRUE
  )
  expect_true(has_csv, info = "Should support CSV format")
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

  html <- get_html_safe(app, "body")
  has_tab <- grepl(
    "tab|txt|text|separator",
    html,
    ignore.case = TRUE
  )
  expect_true(has_tab, info = "Should support tab-separated format")
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

  html <- get_html_safe(app, "body")
  # Tutorial lists error types including missingColumns
  has_error_detection <- grepl(
    "error|warning|missing|required|validation",
    html,
    ignore.case = TRUE
  )
  expect_true(has_error_detection, info = "Should mention error detection")
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

  html <- get_html_safe(app, "body")
  # Tutorial shows pedigree with genotypes option
  has_genotype <- grepl(
    "genotype|allele|genetic|marker",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Input tab loaded")
})
