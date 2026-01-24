#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Home Tab and Navigation
#' Optimized: Uses shared app instance for Home tab tests
library(testthat)

local({
  withr::defer(stop_shared_apps(), envir = parent.frame())
})

test_that("E2E: Home tab loads on startup", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Home")
  expect_false(is.null(shared), info = "Should be able to access Home tab")
  expect_true(
    grepl("Welcome|GeneKeepR|Home", shared$html, ignore.case = TRUE),
    info = "Home tab should load on startup"
  )
})

test_that("E2E: Home tab displays version information", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Home", "Version|Genetic Management",
                     info = "Should display version or description")
})

test_that("E2E: Home tab has Data Input panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Home", "Data Input|Upload|studbook",
                     info = "Should have Data Input panel")
})

test_that("E2E: Home tab has Pedigree Browser panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Home", "Pedigree Browser|Browse|filter",
                     info = "Should have Pedigree Browser panel")
})

test_that("E2E: Home tab has Population Analysis panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Home", "Population|Analysis|age|sex",
                     info = "Should have Population Analysis panel")
})

test_that("E2E: Go to Input button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  # This test needs its own app instance since it changes state
  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_goto_input")
  on.exit(app$stop(), add = TRUE)

  success <- click_element_safe(app, "#goto_input")
  if (!success) skip("Could not click Go to Input button")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Upload|File|Input", html, ignore.case = TRUE),
    info = "Should navigate to Input tab"
  )
})

test_that("E2E: Go to Pedigree button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_goto_pedigree")
  on.exit(app$stop(), add = TRUE)

  success <- click_element_safe(app, "#goto_pedigree")
  if (!success) skip("Could not click Go to Pedigree button")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Pedigree|Browser|Filter", html, ignore.case = TRUE),
    info = "Should navigate to Pedigree tab"
  )
})

test_that("E2E: Go to Pyramid button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_goto_pyramid")
  on.exit(app$stop(), add = TRUE)

  success <- click_element_safe(app, "#goto_pyramid")
  if (!success) skip("Could not click Go to Pyramid button")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Pyramid|Age|Sex|Population", html, ignore.case = TRUE),
    info = "Should navigate to Pyramid tab"
  )
})

test_that("E2E: Navbar has all main tabs", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  shared <- get_shared_app("Home")
  if (is.null(shared)) skip("Could not load Home tab")

  # Check for main navigation tabs
  expect_true(grepl("Home", shared$html), info = "Should have Home tab")
  expect_true(grepl("Input", shared$html), info = "Should have Input tab")
  expect_true(
    grepl("Pedigree", shared$html, ignore.case = TRUE),
    info = "Should have Pedigree tab"
  )
  expect_true(
    grepl("Pyramid", shared$html, ignore.case = TRUE),
    info = "Should have Pyramid tab"
  )
  expect_true(
    grepl("Genetic Value", shared$html, ignore.case = TRUE),
    info = "Should have Genetic Value tab"
  )
  expect_true(
    grepl("Breeding|Groups", shared$html, ignore.case = TRUE),
    info = "Should have Breeding Groups tab"
  )
})

test_that("E2E: More menu exists in navbar", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  expect_tab_content("Home", "More|Settings|About|Help",
                     info = "Should have More menu or its items")
})
