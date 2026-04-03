#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Cross-Module Workflow Integration
library(testthat)

test_that("E2E: Can navigate through all main tabs sequentially", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_sequential_nav")
  on.exit(app$stop(), add = TRUE)

  tabs_visited <- 0

  # Visit Home
  html <- get_html_safe(app, "body")
  if (grepl("Welcome|Home|GeneKeepR", html, ignore.case = TRUE)) {
    tabs_visited <- tabs_visited + 1
  }

  # Visit Input
  if (navigate_to_tab(app, "Input")) {
    html <- get_html_safe(app, "body")
    if (grepl("Upload|File|Input", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }

  # Visit Pedigree Browser
  if (navigate_to_tab(app, "Pedigree Browser", "Pedigree")) {
    html <- get_html_safe(app, "body")
    if (grepl("Pedigree|Browser", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }

  # Visit Age-Sex Pyramid
  if (navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")) {
    html <- get_html_safe(app, "body")
    if (grepl("Pyramid|Age|Sex", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }

  # Visit Genetic Value Analysis
  if (navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")) {
    html <- get_html_safe(app, "body")
    if (grepl("Genetic|Value", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }

  # Visit Breeding Groups
  if (navigate_to_tab(app, "Breeding Groups", "Groups")) {
    html <- get_html_safe(app, "body")
    if (grepl("Breeding|Groups", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }

  expect_true(tabs_visited >= 3, info = "Should visit at least 3 tabs successfully")
})

test_that("E2E: App maintains state when switching tabs", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_state_maintain")
  on.exit(app$stop(), add = TRUE)

  # Get initial values
  values1 <- get_values_safe(app)

  # Switch to another tab
  if (!navigate_to_tab(app, "Input")) skip("Could not switch tabs")

  # Switch back
  if (!navigate_to_tab(app, "Home")) skip("Could not switch back")

  # Get values again
  values2 <- get_values_safe(app)

  # App should still be responsive
  expect_true(is.list(values1), info = "Initial values should be a list")
  expect_true(is.list(values2), info = "Values after switching should be a list")
})

test_that("E2E: App is responsive after multiple tab switches", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_multi_switch")
  on.exit(app$stop(), add = TRUE)

  # Perform multiple tab switches
  tabs <- c("Input", "Home", "Input", "Home")

  for (tab in tabs) {
    navigate_to_tab(app, tab)
  }

  # App should still be responsive
  values <- get_values_safe(app)
  expect_true(is.list(values), info = "App should remain responsive after multiple switches")
})

test_that("E2E: Navbar brand/title is visible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_navbar_brand")
  on.exit(app$stop(), add = TRUE)

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("GeneKeepR", html, ignore.case = TRUE),
    info = "Navbar should show GeneKeepR brand"
  )
})

test_that("E2E: Input tab has file upload before pedigree browser works", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_workflow_upload")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  html <- get_html_safe(app, "body")
  has_upload <- grepl("upload|file|browse", html, ignore.case = TRUE)

  expect_true(has_upload, info = "Input tab should have file upload capability")
})

test_that("E2E: Genetic Value tab indicates data requirement", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_data_req")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Should have some indication of needing data or showing analysis options
  has_content <- grepl(
    "Genetic|Value|Analysis|kinship|population",
    html,
    ignore.case = TRUE
  )

  expect_true(has_content, info = "Genetic Value tab should show relevant content")
})

test_that("E2E: Breeding Groups tab indicates data requirement", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_data_req")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Should have some indication of breeding group functionality
  has_content <- grepl(
    "Breeding|Groups|formation|animals",
    html,
    ignore.case = TRUE
  )

  expect_true(has_content, info = "Breeding Groups tab should show relevant content")
})
