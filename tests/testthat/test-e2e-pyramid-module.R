#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Age-Sex Pyramid Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Age-Sex Pyramid tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Age-Sex Pyramid", "Pyramid")
  expect_false(is.null(shared), info = "Should be able to access Age-Sex Pyramid tab")
  expect_true(
    grepl("Pyramid|Age|Sex", shared$html, ignore.case = TRUE),
    info = "Should be on Age-Sex Pyramid tab"
  )
})

test_that("E2E: Pyramid has age unit selector", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "Years|Months|unit",
                     alt_tab = "Pyramid", info = "Should have age unit selector")
})

test_that("E2E: Pyramid has bin size control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "bin|size|interval",
                     alt_tab = "Pyramid", info = "Should have bin size control")
})

test_that("E2E: Pyramid has color scheme option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "color|viridis|scheme|palette",
                     alt_tab = "Pyramid", info = "Should have color scheme option")
})

test_that("E2E: Pyramid has download button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "download|export|save",
                     alt_tab = "Pyramid", info = "Should have download functionality")
})

test_that("E2E: Pyramid has plot height control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Age-Sex Pyramid", "height|size|dimension",
                     alt_tab = "Pyramid", info = "Should have plot height control")
})
