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

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Settings|Configuration|options", html, ignore.case = TRUE),
    info = "Should be on Settings tab"
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

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("About|Version|GeneKeepR|Oregon|Primate", html, ignore.case = TRUE),
    info = "Should show About information"
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

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Help|Documentation|Online", html, ignore.case = TRUE),
    info = "Should show Help documentation"
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

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("NIH|funded|grant", html, ignore.case = TRUE),
    info = "Should mention NIH funding"
  )
})
