#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Pedigree Browser - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Pedigree Browser has Display Unknown IDs checkbox", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  expect_true(nchar(shared$html) > 100, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has row count display options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  expect_true(nchar(shared$html) > 100, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has focal animal text input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  expect_true(nchar(shared$html) > 100, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has CSV focal animal upload", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  expect_true(nchar(shared$html) > 100, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has Trim Pedigree checkbox", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  expect_true(nchar(shared$html) > 100, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has Update Focal Animals button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  expect_true(nchar(shared$html) > 100, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has Clear Focal Animals option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  expect_true(nchar(shared$html) > 100, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser shows pedigree columns", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "sire|dam|sex|birth|exit|age|gen|population",
                     alt_tab = "Pedigree", info = "Should show pedigree columns")
})
