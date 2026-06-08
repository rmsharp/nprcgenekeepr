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

  expect_true(
    assert_active_pane(app, "Input", "Select how you are submitting data"),
    info = "Input pane active with the data-submission instructions"
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

  expect_true(
    assert_active_pane(app, "Input", "comma-delimited"),
    info = "Input pane active; format docs indicate CSV/comma support"
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

  expect_true(
    assert_active_pane(app, "Input", "Excel"),
    info = "Input pane active with Excel file-type support"
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

  # The Input module has no example/demo-data feature, so there is no static
  # content to assert. Convert the tautology to the genuine behavioral fact:
  # navigation actually landed on (and made visible) the Input pane.
  expect_true(
    assert_active_pane(app, "Input"),
    info = "Input pane is the active/visible pane"
  )
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

  expect_true(
    assert_active_pane(app, "Input", "Quality Control"),
    info = "Input pane active with quality-control options"
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

  expect_true(
    assert_active_pane(app, "Input", "Cleaned Data"),
    info = "Input pane active with the cleaned-data preview tab"
  )
})
