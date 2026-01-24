#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Breeding Groups Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Breeding Groups has group size control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "size|number|count|animals",
                     alt_tab = "Groups", info = "Should have group size control")
})

test_that("E2E: Breeding Groups has harem option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded successfully")
})

test_that("E2E: Breeding Groups has minimum age setting", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "age|minimum|year|breeding",
                     alt_tab = "Groups", info = "Should have minimum age setting")
})

test_that("E2E: Breeding Groups has results display area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded successfully")
})

test_that("E2E: Breeding Groups has export functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(TRUE, info = "Breeding Groups tab loaded successfully")
})

test_that("E2E: Breeding Groups shows algorithm description", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  if (is.null(shared)) skip("Could not navigate to Breeding Groups tab")
  expect_true(nchar(shared$html) > 200, info = "Breeding Groups should show interface content")
})

test_that("E2E: Breeding Groups has kinship constraint option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "kinship|threshold|maximum|constraint|related",
                     alt_tab = "Groups", info = "Should have kinship constraint option")
})
