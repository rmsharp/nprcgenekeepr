#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Pedigree Browser Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Pedigree Browser tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  expect_false(is.null(shared), info = "Should be able to access Pedigree Browser tab")
  expect_true(
    grepl("Pedigree|Browser|Animal", shared$html, ignore.case = TRUE),
    info = "Should be on Pedigree Browser tab"
  )
})

test_that("E2E: Pedigree Browser has focal animal controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "focal|animal|filter|update",
                     alt_tab = "Pedigree", info = "Should have focal animal controls")
})

test_that("E2E: Pedigree Browser has export functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "export|download|csv",
                     alt_tab = "Pedigree", info = "Should have export functionality")
})

test_that("E2E: Pedigree Browser has data table", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "dataTable|dataTables|table",
                     alt_tab = "Pedigree", info = "Should have data table element")
})

test_that("E2E: Pedigree Browser trim pedigree option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "trim|subset|filter",
                     alt_tab = "Pedigree", info = "Should have trim pedigree option")
})
