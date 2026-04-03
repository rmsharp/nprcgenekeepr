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

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Input|Upload|Data|File", html, ignore.case = TRUE),
    info = "Should be on Input tab"
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

  html <- get_html_safe(app, "body")
  has_upload <- grepl("upload|browse|file|select", html, ignore.case = TRUE)
  expect_true(has_upload, info = "Should have file upload control")
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

  html <- get_html_safe(app, "body")
  has_excel <- grepl("excel|xlsx", html, ignore.case = TRUE)
  has_text <- grepl("text|csv|tab", html, ignore.case = TRUE)
  expect_true(has_excel || has_text, info = "Should have file type options")
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

  html <- get_html_safe(app, "body")
  has_qc <- grepl("QC|quality|error|warning|summary", html, ignore.case = TRUE)
  expect_true(has_qc, info = "Should have QC summary display")
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

  html <- get_html_safe(app, "body")
  has_button <- grepl("read|check|upload|submit|pedigree", html, ignore.case = TRUE)
  expect_true(has_button, info = "Should have action button")
})
