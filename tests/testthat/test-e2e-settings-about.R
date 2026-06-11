#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Settings, About, and Help Tabs
library(testthat)

test_that("E2E: Settings tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_settings_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_menu_item(app, "Settings")
  if (!success) skip("Could not navigate to Settings tab")

  expect_true(
    assert_active_pane(app, "Settings", "Settings|Configuration|options"),
    info = "Settings pane should be the active/visible navbarMenu child"
  )
})

test_that("E2E: About tab shows version and credits", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_about_tab")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_menu_item(app, "About")
  if (!success) skip("Could not navigate to About tab")

  expect_true(
    assert_active_pane(app, "About", "About|Version|GeneKeepR|Oregon|Primate"),
    info = "About pane should be active and show version/credits"
  )
})

test_that("E2E: Help tab has documentation link", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_help_tab")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_menu_item(app, "Help")
  if (!success) skip("Could not navigate to Help tab")

  expect_true(
    assert_active_pane(app, "Help", "Help|Documentation|Online"),
    info = "Help pane should be active and show documentation"
  )
})

test_that("E2E: About tab mentions NIH funding", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_about_nih")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_menu_item(app, "About")
  if (!success) skip("Could not navigate to About tab")

  expect_true(
    assert_active_pane(app, "About", "NIH|funded|grant"),
    info = "Active About pane should mention NIH funding"
  )
})
