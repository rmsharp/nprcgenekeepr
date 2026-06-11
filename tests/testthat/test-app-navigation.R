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

  # Initial state: the app boots with the Home pane active/visible.
  expect_true(
    assert_active_pane(app, "Home"),
    info = "App should boot to the Home pane"
  )

  # Clicking the Input navbar tab anchor switches the active/visible pane to
  # Input (a real navigation, not merely "the body is non-empty").
  success <- click_element_safe(app, 'a[data-value="Input"]')
  if (!success) skip("Input tab anchor not clickable")
  expect_true(
    assert_active_pane(app, "Input", "Data Input and Quality Control"),
    info = "Clicking the Input tab should switch the active pane to Input"
  )
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

  # The app is responsive: get_values() returns a list, and the mainNavbar
  # input reads back its startup default ("Home") -- a real state check, not
  # merely "is it a list".
  values <- get_values_safe(app)
  expect_true(is.list(values), info = "get_values() should return a list")
  expect_identical(app$get_value(input = "mainNavbar"), "Home")
})
