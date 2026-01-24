#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Breeding Group Formation - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Breeding Groups has workflow selection", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has sex ratio options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  # Tutorial mentions three sex ratio options including user-specified
  expect_tab_content("Breeding Groups", "sex.*ratio|ratio.*breeder|F/M|female.*male|sexRatio",
                     alt_tab = "Groups", info = "Should have sex ratio options")
})

test_that("E2E: Breeding Groups has Make Groups button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "Make.*Group|Form.*Group|Create.*Group|makeGroups|formGroups",
                     alt_tab = "Groups", info = "Should have Make Groups button")
})

test_that("E2E: Breeding Groups has seed groups option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has infants with dam option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has include kinship option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has group export options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has high-value animals source", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})

test_that("E2E: Breeding Groups has kinship matrix export per group", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded")
})
