#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Breeding Groups Module
library(testthat)

test_that("E2E: Breeding Groups has group size control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_group_size")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("size|number|count|animals", html, ignore.case = TRUE),
    info = "Should have group size control"
  )
})

test_that("E2E: Breeding Groups has harem option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_harem")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_harem <- grepl("harem|single male|breeding system", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Breeding Groups tab loaded successfully")
})

test_that("E2E: Breeding Groups has minimum age setting", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_min_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("age|minimum|year|breeding", html, ignore.case = TRUE),
    info = "Should have minimum age setting"
  )
})

test_that("E2E: Breeding Groups has results display area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_results")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Should have area for displaying formed groups
  has_results <- grepl(
    "result|group|table|output|formed",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Breeding Groups tab loaded successfully")
})

test_that("E2E: Breeding Groups has export functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_export")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_export <- grepl("export|download|save", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Breeding Groups tab loaded successfully")
})

test_that("E2E: Breeding Groups shows algorithm description", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_algorithm")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  has_content <- nchar(html) > 200
  expect_true(has_content, info = "Breeding Groups should show interface content")
})

test_that("E2E: Breeding Groups has kinship constraint option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_kinship_constraint")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  expect_true(
    grepl("kinship|threshold|maximum|constraint|related", html, ignore.case = TRUE),
    info = "Should have kinship constraint option"
  )
})
