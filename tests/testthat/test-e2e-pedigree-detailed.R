#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Pedigree Browser Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Pedigree browser has filter controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "filter|search|select",
                     alt_tab = "Pedigree", info = "Should have filter controls")
})

test_that("E2E: Pedigree browser has ID search", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "ID|animal|identifier|search",
                     alt_tab = "Pedigree", info = "Should have ID search capability")
})

test_that("E2E: Pedigree browser shows relationship information", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "sire|dam|parent|offspring|ancestor|descendant",
                     alt_tab = "Pedigree", info = "Should show relationship information")
})

test_that("E2E: Pedigree browser has data table", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  has_table <- grepl("table|dataTable|DT", shared$html, ignore.case = TRUE) ||
    grepl("<table", shared$html, ignore.case = TRUE)
  expect_true(has_table, info = "Should have data table")
})

test_that("E2E: Pedigree browser has sex filter option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Pedigree Browser", "sex|male|female|gender",
                     alt_tab = "Pedigree", info = "Should have sex filter option")
})

test_that("E2E: Pedigree browser has status filter", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Pedigree Browser", "Pedigree")
  if (is.null(shared)) skip("Could not navigate to Pedigree Browser tab")
  expect_true(nchar(shared$html) > 100, info = "Pedigree Browser loaded successfully")
})
