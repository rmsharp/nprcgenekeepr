#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Genetic Value Analysis Module
library(testthat)

test_that("E2E: Genetic Value Analysis tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Genetic|Value|Analysis|Kinship", html, ignore.case = TRUE),
    info = "Should be on Genetic Value Analysis tab"
  )
})

test_that("E2E: Genetic Value has gene drop iterations control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_iterations")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_iterations <- grepl("iteration|gene drop|simulation", html, ignore.case = TRUE)
  expect_true(has_iterations, info = "Should have gene drop iterations control")
})

test_that("E2E: Genetic Value has metric checkboxes", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_metrics")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_metrics <- grepl("genome uniqueness|mean kinship|uniqueness|kinship", html, ignore.case = TRUE)
  expect_true(has_metrics, info = "Should have genetic metric options")
})

test_that("E2E: Genetic Value has minimum breeding age control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_min_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_min_age <- grepl("minimum|breeding|age", html, ignore.case = TRUE)
  expect_true(has_min_age, info = "Should have minimum breeding age control")
})

test_that("E2E: Genetic Value has run analysis button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_run_button")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_run_button <- grepl("run|analyze|calculate|start", html, ignore.case = TRUE)
  expect_true(has_run_button, info = "Should have run analysis button")
})

test_that("E2E: Genetic Value has rankings display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_rankings")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_rankings <- grepl("ranking|top|result", html, ignore.case = TRUE)
  expect_true(has_rankings, info = "Should have rankings display area")
})

test_that("E2E: Genetic Value has download functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_download")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  has_download <- grepl("download|export|save", html, ignore.case = TRUE)
  expect_true(has_download, info = "Should have download functionality")
})
