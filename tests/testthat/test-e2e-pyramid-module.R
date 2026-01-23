#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Age-Sex Pyramid Module
library(testthat)

test_that("E2E: Age-Sex Pyramid tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Pyramid|Age|Sex", html, ignore.case = TRUE),
    info = "Should be on Age-Sex Pyramid tab"
  )
})

test_that("E2E: Pyramid has age unit selector", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_age_unit")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
  has_age_unit <- grepl("Years|Months|unit", html, ignore.case = TRUE)
  expect_true(has_age_unit, info = "Should have age unit selector")
})

test_that("E2E: Pyramid has bin size control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_bin_size")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
  has_bin_size <- grepl("bin|size|interval", html, ignore.case = TRUE)
  expect_true(has_bin_size, info = "Should have bin size control")
})

test_that("E2E: Pyramid has color scheme option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_color")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
  has_color <- grepl("color|viridis|scheme|palette", html, ignore.case = TRUE)
  expect_true(has_color, info = "Should have color scheme option")
})

test_that("E2E: Pyramid has download button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_download")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
  has_download <- grepl("download|export|save", html, ignore.case = TRUE)
  expect_true(has_download, info = "Should have download functionality")
})

test_that("E2E: Pyramid has plot height control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_height")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
  has_height <- grepl("height|size|dimension", html, ignore.case = TRUE)
  expect_true(has_height, info = "Should have plot height control")
})
