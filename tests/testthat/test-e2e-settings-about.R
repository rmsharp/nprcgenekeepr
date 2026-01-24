#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Settings, About, and Help Tabs
#' Optimized: Uses shared app instance for menu item tests
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Settings tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Settings", "Settings|Configuration|options",
                     menu_item = TRUE, info = "Should be on Settings tab")
})

test_that("E2E: About tab shows version and credits", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("About", "About|Version|GeneKeepR|Oregon|Primate",
                     menu_item = TRUE, info = "Should show About information")
})

test_that("E2E: Help tab has documentation link", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Help", "Help|Documentation|Online",
                     menu_item = TRUE, info = "Should show Help documentation")
})

test_that("E2E: About tab mentions NIH funding", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("About", "NIH|funded|grant",
                     menu_item = TRUE, info = "Should mention NIH funding")
})
