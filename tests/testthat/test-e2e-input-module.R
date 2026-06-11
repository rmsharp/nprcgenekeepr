#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Input Module
library(testthat)

test_that("E2E: Input tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "Data Input and Quality Control"),
    info = "Input pane active with its data-input/QC heading"
  )
})

test_that("E2E: Input tab has file upload control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_upload")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "Select Pedigree File"),
    info = "Input pane active with the file-upload control"
  )
})

test_that("E2E: Input tab has file type options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_filetypes")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "File Type"),
    info = "Input pane active with the file-type options"
  )
})

test_that("E2E: Input tab has QC summary display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_qc")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "QC Summary"),
    info = "Input pane active with the QC summary tab"
  )
})

test_that("E2E: Input tab has action button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_action")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "Read and Check Pedigree"),
    info = "Input pane active with the read-and-check action button"
  )
})
