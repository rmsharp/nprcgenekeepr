#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Genetic Value Analysis Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Genetic Value Analysis tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Genetic Value Analysis", "Genetic Value")
  expect_false(is.null(shared), info = "Should be able to access Genetic Value tab")
  expect_true(
    grepl("Genetic|Value|Analysis|Kinship", shared$html, ignore.case = TRUE),
    info = "Should be on Genetic Value Analysis tab"
  )
})

test_that("E2E: Genetic Value has gene drop iterations control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "iteration|gene drop|simulation",
                     alt_tab = "Genetic Value", info = "Should have gene drop iterations control")
})

test_that("E2E: Genetic Value has metric checkboxes", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "genome uniqueness|mean kinship|uniqueness|kinship",
                     alt_tab = "Genetic Value", info = "Should have genetic metric options")
})

test_that("E2E: Genetic Value has minimum breeding age control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "minimum|breeding|age",
                     alt_tab = "Genetic Value", info = "Should have minimum breeding age control")
})

test_that("E2E: Genetic Value has run analysis button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "run|analyze|calculate|start",
                     alt_tab = "Genetic Value", info = "Should have run analysis button")
})

test_that("E2E: Genetic Value has rankings display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "ranking|top|result",
                     alt_tab = "Genetic Value", info = "Should have rankings display area")
})

test_that("E2E: Genetic Value has download functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Genetic Value Analysis", "download|export|save",
                     alt_tab = "Genetic Value", info = "Should have download functionality")
})
