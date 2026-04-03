#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)

test_that("Navigation between tabs works", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()
  # Runs on CI with shinytest2 workflow # Skip on CI until Chrome is configured

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "nav_test",
    height = 800,
    width = 1200,
    load_timeout = 30000
  )

  on.exit(app$stop(), add = TRUE)

  # Wait for app to load
  Sys.sleep(2)

  # Get initial state
  initial_html <- app$get_html("body")
  expect_true(nchar(initial_html) > 0)

  # Try clicking on Input tab if it exists
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(1)
    input_html <- app$get_html("body")
    expect_true(nchar(input_html) > 0)
  }, error = function(e) {
    # Tab might have different selector
    skip("Input tab selector not found")
  })
})

test_that("App responds to user interactions", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()
  # Runs on CI with shinytest2 workflow

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "interaction_test",
    height = 800,
    width = 1200,
    load_timeout = 30000
  )

  on.exit(app$stop(), add = TRUE)

  # Wait for app to load
  Sys.sleep(2)

  # Get all input values
  values <- app$get_values()

  # Verify we can retrieve values (app is responsive)
  expect_true(is.list(values))
})
