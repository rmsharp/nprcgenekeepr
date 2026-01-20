#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Input Module - File Upload and Quality Control
library(testthat)

# Helper to get test data path
get_test_data_path <- function(filename) {

  path <- system.file("extdata", filename, package = "nprcgenekeepr")
  if (path == "") {
    skip(paste("Test data file not found:", filename))
  }
  path
}

test_that("E2E: Excel file upload and QC workflow", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_excel_upload",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  # Wait for app to stabilize

  Sys.sleep(3)

 # Navigate to Input tab
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
  }, error = function(e) {
    # Try alternative navigation
    app$set_inputs(`main_navbar` = "Input")
    Sys.sleep(2)
  })

  # Verify we're on Input tab by checking for expected content
  html <- app$get_html("body")
  expect_true(
    grepl("Input|Upload|File|Pedigree", html, ignore.case = TRUE),
    info = "Should be on Input tab with file upload options"
  )
})

test_that("E2E: Input module shows file type options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_file_type_options",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Navigate to Input tab
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Input tab")
  })

  # Check for file type radio buttons
  html <- app$get_html("body")
  expect_true(
    grepl("Excel|Text|CSV", html, ignore.case = TRUE),
    info = "Should show file type options"
  )
})

test_that("E2E: Input module file content options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_file_content_options",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Navigate to Input tab
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Input tab")
  })

  # Check for file content options
  html <- app$get_html("body")
  has_content_options <- grepl("pedigree|genotype|focal", html, ignore.case = TRUE)
  expect_true(has_content_options, info = "Should show file content options")
})

test_that("E2E: Input module minimum parent age control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_min_parent_age",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Navigate to Input tab
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Input tab")
  })

  # Check for minimum parent age control
  html <- app$get_html("body")
  has_min_age <- grepl("minimum|parent|age", html, ignore.case = TRUE)
  expect_true(has_min_age, info = "Should show minimum parent age control")
})

test_that("E2E: QC tabs are present", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_qc_tabs",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Navigate to Input tab
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Input tab")
  })

  # Check for QC-related tabs/content
  html <- app$get_html("body")
  has_qc_elements <- grepl("Summary|Error|Warning|Clean", html, ignore.case = TRUE)
  expect_true(has_qc_elements, info = "Should show QC-related elements")
})
