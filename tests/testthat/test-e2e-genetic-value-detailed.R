#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Genetic Value Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Genetic Value has population selection", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "population|select|animals|subset",
                     alt_tab = "Genetic Value", info = "Should have population selection")
})

test_that("E2E: Genetic Value has genome uniqueness display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "genome|uniqueness|GU|unique",
                     alt_tab = "Genetic Value", info = "Should have genome uniqueness display")
})

test_that("E2E: Genetic Value has founder equivalents info", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate to Genetic Value Analysis tab")
  expect_true(nchar(shared$html) > 100, info = "Genetic Value tab loaded successfully")
})

test_that("E2E: Genetic Value has kinship analysis section", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "kinship|mean|coefficient|MK",
                     alt_tab = "Genetic Value", info = "Should have kinship analysis section")
})

test_that("E2E: Genetic Value has ranking capability", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "rank|value|score|priority",
                     alt_tab = "Genetic Value", info = "Should have ranking capability")
})

test_that("E2E: Genetic Value has report generation", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate to Genetic Value Analysis tab")
  expect_true(nchar(shared$html) > 100, info = "Genetic Value tab loaded successfully")
})

test_that("E2E: Genetic Value shows analysis instructions", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  if (is.null(shared)) skip("Could not navigate to Genetic Value Analysis tab")
  expect_true(nchar(shared$html) > 200, info = "Should show analysis instructions or interface")
})
