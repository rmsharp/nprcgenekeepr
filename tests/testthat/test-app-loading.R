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

  # Behavioral: the app boots with the Home pane active+visible (read from the
  # live DOM's single visible pane), not merely that the driver constructed.
  expect_true(
    assert_active_pane(app, "Home", "Welcome to GeneKeepR"),
    info = "App should boot to the Home pane"
  )
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

  # Check that the main navbar tab anchors are wired (structural). These live
  # outside any tab-pane (navbar <ul>), so this stays a DOM-structure check --
  # but asserts the real tab anchors exist, not just a substring in the body
  # (which the Home pane's "Go to Input" button text would also satisfy).
  expect_true(
    wait_for_element(app, 'a[data-value="Input"]') &&
      wait_for_element(app, 'a[data-value="Pedigree Browser"]') &&
      wait_for_element(app, 'a[data-value="Age-Sex Pyramid"]'),
    info = "Navbar should wire the Input/Pedigree/Pyramid tab anchors"
  )
})
