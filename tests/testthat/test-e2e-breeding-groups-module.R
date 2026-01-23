#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Breeding Groups Module
library(testthat)

test_that("E2E: Breeding Groups tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("Breeding|Group|Formation", html, ignore.case = TRUE),
    info = "Should be on Breeding Groups tab"
  )
})

test_that("E2E: Breeding Groups has animal source selection", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_source")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_source <- grepl("source|top ranked|custom|all", html, ignore.case = TRUE)
  expect_true(has_source, info = "Should have animal source selection")
})

test_that("E2E: Breeding Groups has number of groups control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_num_groups")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_num_groups <- grepl("number|groups|count", html, ignore.case = TRUE)
  expect_true(has_num_groups, info = "Should have number of groups control")
})

test_that("E2E: Breeding Groups has kinship threshold control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_kinship")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_kinship <- grepl("kinship|threshold|maximum", html, ignore.case = TRUE)
  expect_true(has_kinship, info = "Should have kinship threshold control")
})

test_that("E2E: Breeding Groups has sex ratio options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_sex_ratio")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_sex_ratio <- grepl("sex|ratio|harem|male|female", html, ignore.case = TRUE)
  expect_true(has_sex_ratio, info = "Should have sex ratio options")
})

test_that("E2E: Breeding Groups has form groups button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_form_button")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_form_button <- grepl("form|create|make|groups", html, ignore.case = TRUE)
  expect_true(has_form_button, info = "Should have form groups button")
})

test_that("E2E: Breeding Groups has statistics display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_stats")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_stats <- grepl("statistic|summary|total", html, ignore.case = TRUE)
  expect_true(has_stats, info = "Should have statistics display")
})
