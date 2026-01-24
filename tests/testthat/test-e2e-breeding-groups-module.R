#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Breeding Groups Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Breeding Groups tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Breeding Groups", "Groups")
  expect_false(is.null(shared), info = "Should be able to access Breeding Groups tab")
  expect_true(
    grepl("Breeding|Group|Formation", shared$html, ignore.case = TRUE),
    info = "Should be on Breeding Groups tab"
  )
})

test_that("E2E: Breeding Groups has animal source selection", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "source|top ranked|custom|all",
                     alt_tab = "Groups", info = "Should have animal source selection")
})

test_that("E2E: Breeding Groups has number of groups control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "number|groups|count",
                     alt_tab = "Groups", info = "Should have number of groups control")
})

test_that("E2E: Breeding Groups has kinship threshold control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "kinship|threshold|maximum",
                     alt_tab = "Groups", info = "Should have kinship threshold control")
})

test_that("E2E: Breeding Groups has sex ratio options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "sex|ratio|harem|male|female",
                     alt_tab = "Groups", info = "Should have sex ratio options")
})

test_that("E2E: Breeding Groups has form groups button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "form|create|make|groups",
                     alt_tab = "Groups", info = "Should have form groups button")
})

test_that("E2E: Breeding Groups has statistics display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Breeding Groups", "statistic|summary|total",
                     alt_tab = "Groups", info = "Should have statistics display")
})
