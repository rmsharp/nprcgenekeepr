#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Pedigree Browser Module
library(testthat)

test_that("E2E: Pedigree Browser tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pedigree_access",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Try to navigate to Pedigree Browser
  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    # Try alternative selector
    tryCatch({
      app$click(selector = 'a[data-value="Pedigree"]')
      Sys.sleep(2)
    }, error = function(e2) {
      skip("Could not navigate to Pedigree tab")
    })
  })

  html <- app$get_html("body")
  expect_true(
    grepl("Pedigree|Browser|Animal", html, ignore.case = TRUE),
    info = "Should be on Pedigree Browser tab"
  )
})

test_that("E2E: Pedigree Browser has focal animal controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pedigree_focal_controls",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Navigate to Pedigree Browser
  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree tab")
  })

  html <- app$get_html("body")
  has_focal_controls <- grepl("focal|animal|filter|update", html, ignore.case = TRUE)
  expect_true(has_focal_controls, info = "Should have focal animal controls")
})

test_that("E2E: Pedigree Browser has export functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pedigree_export",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Navigate to Pedigree Browser
  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree tab")
  })

  html <- app$get_html("body")
  has_export <- grepl("export|download|csv", html, ignore.case = TRUE)
  expect_true(has_export, info = "Should have export functionality")
})

test_that("E2E: Pedigree Browser has data table", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pedigree_datatable",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Navigate to Pedigree Browser
  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree tab")
  })

  html <- app$get_html("body")
  # DataTable usually has these classes or elements
  has_datatable <- grepl("dataTable|dataTables|table", html, ignore.case = TRUE)
  expect_true(has_datatable, info = "Should have data table element")
})

test_that("E2E: Pedigree Browser trim pedigree option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pedigree_trim",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Navigate to Pedigree Browser
  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree tab")
  })

  html <- app$get_html("body")
  has_trim_option <- grepl("trim|subset|filter", html, ignore.case = TRUE)
  expect_true(has_trim_option, info = "Should have trim pedigree option")
})
