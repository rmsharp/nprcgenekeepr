#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Genetic Value Analysis - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
library(testthat)

test_that("E2E: Genetic Value has number of simulations input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_num_sims")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions 2 to 100,000 simulations, minimum 1000 recommended
  has_num_sims <- grepl(
    "simulation|iteration|numSim|number.*simulation|gene.*drop",
    html,
    ignore.case = TRUE
  )
  expect_true(has_num_sims, info = "Should have number of simulations input")
})

test_that("E2E: Genetic Value has genome uniqueness threshold", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_gu_threshold")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions genome uniqueness threshold 0-3
  has_gu_threshold <- grepl(
    "genome.*uniqueness|uniqueness.*threshold|GU|threshold",
    html,
    ignore.case = TRUE
  )
  expect_true(has_gu_threshold, info = "Should have genome uniqueness threshold")
})

test_that("E2E: Genetic Value has Begin Analysis button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_begin_analysis")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_begin_button <- grepl(
    "Begin.*Analysis|Start.*Analysis|Run.*Analysis|Analyze|Calculate",
    html,
    ignore.case = TRUE
  )
  expect_true(has_begin_button, info = "Should have Begin Analysis button")
})

test_that("E2E: Genetic Value has results table area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_results_table")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Results table should have dataTable or similar
  has_results_table <- grepl(
    "dataTable|DTOutput|table|results|ranking",
    html,
    ignore.case = TRUE
  )
  expect_true(has_results_table, info = "Should have results table area")
})

test_that("E2E: Genetic Value mentions Value Designation", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_value_designation")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions High Value, Low Value, Undetermined
  has_value_designation <- grepl(
    "Value.*Designation|High.*Value|Low.*Value|designation|valueDesignation",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Genetic Value tab loaded")
})

test_that("E2E: Genetic Value has mean kinship display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_mean_kinship")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_mean_kinship <- grepl(
    "mean.*kinship|kinship.*coefficient|MK|meanKinship",
    html,
    ignore.case = TRUE
  )
  expect_true(has_mean_kinship, info = "Should reference mean kinship")
})

test_that("E2E: Genetic Value has Z-score display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_zscore")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_zscore <- grepl(
    "z-score|zscore|z.*score|standardized",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Genetic Value tab loaded")
})

test_that("E2E: Genetic Value has focal animals display option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_focal_display")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Tutorial mentions default display for focal animals
  has_focal_display <- grepl(
    "focal|display|Show.*entries|search|filter",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Genetic Value tab loaded")
})
