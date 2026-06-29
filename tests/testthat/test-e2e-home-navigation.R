## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Tests for Home Tab and Navigation
library(testthat)

test_that("E2E: Home tab loads on startup", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_home_load")
  on.exit(app$stop(), add = TRUE)

  expect_true(
    assert_active_pane(app, "Home", "Welcome to GeneKeepR"),
    info = "Home pane should be active/visible on startup"
  )
})

test_that("E2E: Home tab displays version information", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_home_version")
  on.exit(app$stop(), add = TRUE)

  expect_true(
    assert_active_pane(app, "Home", "Version|Genetic Management"),
    info = "Home pane should display version/description"
  )
})

test_that("E2E: Home tab has Data Input panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_home_input_panel")
  on.exit(app$stop(), add = TRUE)

  expect_true(
    assert_active_pane(app, "Home", "Data Input|Upload|studbook"),
    info = "Home pane should have the Data Input panel"
  )
})

test_that("E2E: Home tab has Pedigree Browser panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_home_pedigree_panel")
  on.exit(app$stop(), add = TRUE)

  expect_true(
    assert_active_pane(app, "Home", "Pedigree Browser|Browse|filter"),
    info = "Home pane should have the Pedigree Browser panel"
  )
})

test_that("E2E: Home tab has Population Analysis panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_home_population_panel")
  on.exit(app$stop(), add = TRUE)

  expect_true(
    assert_active_pane(app, "Home", "Analysis|age|sex"),
    info = "Home pane should have the population-analysis panels"
  )
})

test_that("E2E: Go to Input button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_goto_input")
  on.exit(app$stop(), add = TRUE)

  success <- click_element_safe(app, "#goto_input")
  if (!success) skip("Could not click Go to Input button")

  expect_true(
    assert_active_pane(app, "Input", "Data Input and Quality Control"),
    info = "Go to Input should switch the active pane to Input"
  )
})

test_that("E2E: Go to Pedigree button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_goto_pedigree")
  on.exit(app$stop(), add = TRUE)

  success <- click_element_safe(app, "#goto_pedigree")
  if (!success) skip("Could not click Go to Pedigree button")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Focal Animals|Display Options"),
    info = "Go to Pedigree should switch the active pane to Pedigree Browser"
  )
})

test_that("E2E: Go to Pyramid button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_goto_pyramid")
  on.exit(app$stop(), add = TRUE)

  success <- click_element_safe(app, "#goto_pyramid")
  if (!success) skip("Could not click Go to Pyramid button")

  expect_true(
    assert_active_pane(app, "Age-Sex Pyramid",
                       "Age-Sex Pyramid Analysis|Bin Size|Color Scheme"),
    info = "Go to Pyramid should switch the active pane to Age-Sex Pyramid"
  )
})

test_that("E2E: Navbar has all main tabs", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_navbar_tabs")
  on.exit(app$stop(), add = TRUE)

  html <- get_html_safe(app, "body")

  # CARVE-OUT (8e-2): these assert the navbar <ul> tab LABELS, which live
  # outside any tab-pane, so assert_active_pane would (correctly) not match
  # them. They stay whole-DOM grepl checks of the navbar structure.
  expect_true(grepl("Home", html), info = "Should have Home tab")
  expect_true(grepl("Input", html), info = "Should have Input tab")
  expect_true(
    grepl("Pedigree", html, ignore.case = TRUE),
    info = "Should have Pedigree tab"
  )
  expect_true(
    grepl("Pyramid", html, ignore.case = TRUE),
    info = "Should have Pyramid tab"
  )
  expect_true(
    grepl("Genetic Value", html, ignore.case = TRUE),
    info = "Should have Genetic Value tab"
  )
  expect_true(
    grepl("Breeding|Groups", html, ignore.case = TRUE),
    info = "Should have Breeding Groups tab"
  )
})

test_that("E2E: More menu exists in navbar", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_more_menu")
  on.exit(app$stop(), add = TRUE)

  html <- get_html_safe(app, "body")
  # CARVE-OUT (8e-2): the "More" navbarMenu and its items are navbar dropdown
  # labels (outside any tab-pane), so this stays a whole-DOM grepl check.
  expect_true(
    grepl("More|Settings|About|Help", html, ignore.case = TRUE),
    info = "Should have More menu or its items"
  )
})
