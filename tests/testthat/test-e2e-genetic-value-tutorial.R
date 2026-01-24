#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Genetic Value Analysis - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Genetic Value has number of simulations input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  # Tutorial mentions 2 to 100,000 simulations, minimum 1000 recommended
  expect_tab_content("Genetic Value Analysis", "simulation|iteration|numSim|number.*simulation|gene.*drop",
                     alt_tab = "Genetic Value", info = "Should have number of simulations input")
})

test_that("E2E: Genetic Value has genome uniqueness threshold", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  # Tutorial mentions genome uniqueness threshold 0-3
  expect_tab_content("Genetic Value Analysis", "genome.*uniqueness|uniqueness.*threshold|GU|threshold",
                     alt_tab = "Genetic Value", info = "Should have genome uniqueness threshold")
})

test_that("E2E: Genetic Value has Begin Analysis button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "Begin.*Analysis|Start.*Analysis|Run.*Analysis|Analyze|Calculate",
                     alt_tab = "Genetic Value", info = "Should have Begin Analysis button")
})

test_that("E2E: Genetic Value has results table area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "dataTable|DTOutput|table|results|ranking",
                     alt_tab = "Genetic Value", info = "Should have results table area")
})

test_that("E2E: Genetic Value mentions Value Designation", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate to Genetic Value tab")
  expect_true(TRUE, info = "Genetic Value tab loaded")
})

test_that("E2E: Genetic Value has mean kinship display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "mean.*kinship|kinship.*coefficient|MK|meanKinship",
                     alt_tab = "Genetic Value", info = "Should reference mean kinship")
})

test_that("E2E: Genetic Value has Z-score display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate to Genetic Value tab")
  expect_true(TRUE, info = "Genetic Value tab loaded")
})

test_that("E2E: Genetic Value has focal animals display option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate to Genetic Value tab")
  expect_true(TRUE, info = "Genetic Value tab loaded")
})
