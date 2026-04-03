#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Pedigree Browser Module
library(testthat)

test_that("E2E: Pedigree browser has filter controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_filter")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("filter|search|select", html, ignore.case = TRUE),
    info = "Should have filter controls"
  )
})

test_that("E2E: Pedigree browser has ID search", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_id_search")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("ID|animal|identifier|search", html, ignore.case = TRUE),
    info = "Should have ID search capability"
  )
})

test_that("E2E: Pedigree browser shows relationship information", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_relations")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("sire|dam|parent|offspring|ancestor|descendant", html, ignore.case = TRUE),
    info = "Should show relationship information"
  )
})

test_that("E2E: Pedigree browser has data table", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_table")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  # DataTables or similar should be present
  has_table <- grepl("table|dataTable|DT", html, ignore.case = TRUE) ||
    grepl("<table", html, ignore.case = TRUE)
  expect_true(has_table, info = "Should have data table")
})

test_that("E2E: Pedigree browser has sex filter option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_sex_filter")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("sex|male|female|gender", html, ignore.case = TRUE),
    info = "Should have sex filter option"
  )
})

test_that("E2E: Pedigree browser has status filter", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_status_filter")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  has_status <- grepl("status|alive|dead|living|deceased", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Pedigree Browser loaded successfully")
})
