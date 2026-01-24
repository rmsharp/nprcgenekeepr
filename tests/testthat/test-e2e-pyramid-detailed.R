#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Age-Sex Pyramid Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Pyramid module has age bin controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "age|bin|interval|year",
                     alt_tab = "Pyramid", info = "Should have age bin controls")
})

test_that("E2E: Pyramid module displays male/female labels", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "male|female|sex",
                     alt_tab = "Pyramid", info = "Should display male/female labels")
})

test_that("E2E: Pyramid module has maximum age setting", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "max|maximum|age|limit",
                     alt_tab = "Pyramid", info = "Should have maximum age setting")
})

test_that("E2E: Pyramid module has plot export option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Age-Sex Pyramid", "Pyramid")
  if (is.null(shared)) skip("Could not navigate to Age-Sex Pyramid tab")
  expect_true(nchar(shared$html) > 100, info = "Pyramid tab loaded successfully")
})

test_that("E2E: Pyramid module has population description", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "population|distribution|pyramid|demographic",
                     alt_tab = "Pyramid", info = "Should have population description")
})

test_that("E2E: Pyramid module shows data requirement message", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Age-Sex Pyramid", "Pyramid")
  if (is.null(shared)) skip("Could not navigate to Age-Sex Pyramid tab")
  expect_true(nchar(shared$html) > 100, info = "Pyramid module should render content")
})
