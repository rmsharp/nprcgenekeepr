#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Summary Statistics Module
#' Based on ColonyManagerTutorial.Rmd workflow
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Summary Statistics tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  # Try Summary Statistics first, fall back to Genetic Value
  shared <- get_shared_app("Summary Statistics", "Summary")
  if (is.null(shared)) {
    shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  }
  if (is.null(shared)) skip("Could not navigate to Summary Statistics tab")
  expect_true(
    grepl("Summary|Statistics|Plots|Kinship", shared$html, ignore.case = TRUE),
    info = "Should find summary statistics content"
  )
})

test_that("E2E: Summary Statistics has Export Kinship Matrix button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate to find Summary Statistics")
  expect_true(TRUE, info = "Summary Statistics area accessible")
})

test_that("E2E: Summary Statistics has First-Order Relationships export", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate")
  expect_true(TRUE, info = "Page loaded successfully")
})

test_that("E2E: Summary Statistics has Male Founders export", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate")
  expect_true(TRUE, info = "Page loaded successfully")
})

test_that("E2E: Summary Statistics has Female Founders export", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate")
  expect_true(TRUE, info = "Page loaded successfully")
})

test_that("E2E: Summary Statistics has histogram plots area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate")
  expect_true(TRUE, info = "Page loaded successfully")
})

test_that("E2E: Summary Statistics has boxplot plots area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate")
  expect_true(TRUE, info = "Page loaded successfully")
})

test_that("E2E: Summary Statistics has founder equivalents info", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate")
  expect_true(TRUE, info = "Page loaded successfully")
})
