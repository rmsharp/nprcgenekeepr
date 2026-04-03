#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)

test_that("GeneKeepR app loads without errors", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()
  # Runs on CI with shinytest2 workflow # Skip on CI until Chrome is configured

  app_dir <- create_test_app()


  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "app_load_test",
    height = 800,
    width = 1200,
    load_timeout = 30000
  )

  on.exit(app$stop(), add = TRUE)

  # Verify app started successfully (app object exists and is valid)
  expect_true(inherits(app, "AppDriver"))

  # Give the app time to fully load

  Sys.sleep(2)

  # Take a screenshot to verify loading
  # app$get_screenshot()
})

test_that("App UI structure is correct", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()
  # Runs on CI with shinytest2 workflow

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "app_ui_test",
    height = 800,
    width = 1200,
    load_timeout = 30000
  )

  on.exit(app$stop(), add = TRUE)

  # Check that main navigation tabs exist
  html <- app$get_html("body")

  # Verify key navigation elements are present
expect_true(grepl("Input|Pedigree|Pyramid", html, ignore.case = TRUE))
})
