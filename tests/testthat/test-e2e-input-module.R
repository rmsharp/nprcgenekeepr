#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Input Module
#' Optimized: Uses shared app instance for all tests on this tab
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Input tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Input")
  expect_false(is.null(shared), info = "Should be able to access Input tab")
  expect_true(
    grepl("Input|Upload|Data|File", shared$html, ignore.case = TRUE),
    info = "Should be on Input tab"
  )
})

test_that("E2E: Input tab has file upload control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "upload|browse|file|select",
                     info = "Should have file upload control")
})

test_that("E2E: Input tab has file type options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Input")
  if (is.null(shared)) skip("Could not navigate to Input tab")
  has_excel <- grepl("excel|xlsx", shared$html, ignore.case = TRUE)
  has_text <- grepl("text|csv|tab", shared$html, ignore.case = TRUE)
  expect_true(has_excel || has_text, info = "Should have file type options")
})

test_that("E2E: Input tab has QC summary display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "QC|quality|error|warning|summary",
                     info = "Should have QC summary display")
})

test_that("E2E: Input tab has action button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Input", "read|check|upload|submit|pedigree",
                     info = "Should have action button")
})
