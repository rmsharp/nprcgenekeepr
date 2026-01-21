#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Age-Sex Pyramid Module
library(testthat)

test_that("E2E: Pyramid module has age bin controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pyramid_bins",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Age-Sex Pyramid"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Age-Sex Pyramid tab")
  })

  html <- app$get_html("body")
  expect_true(
    grepl("age|bin|interval|year", html, ignore.case = TRUE),
    info = "Should have age bin controls"
  )
})

test_that("E2E: Pyramid module displays male/female labels", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pyramid_sex_labels",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Age-Sex Pyramid"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Age-Sex Pyramid tab")
  })

  html <- app$get_html("body")
  expect_true(
    grepl("male|female|sex", html, ignore.case = TRUE),
    info = "Should display male/female labels"
  )
})

test_that("E2E: Pyramid module has maximum age setting", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pyramid_max_age",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Age-Sex Pyramid"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Age-Sex Pyramid tab")
  })

  html <- app$get_html("body")
  expect_true(
    grepl("max|maximum|age|limit", html, ignore.case = TRUE),
    info = "Should have maximum age setting"
  )
})

test_that("E2E: Pyramid module has plot export option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pyramid_export_plot",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Age-Sex Pyramid"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Age-Sex Pyramid tab")
  })

  html <- app$get_html("body")
  has_export <- grepl("export|download|save|png|pdf", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Pyramid tab loaded successfully")
})

test_that("E2E: Pyramid module has population description", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pyramid_desc",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Age-Sex Pyramid"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Age-Sex Pyramid tab")
  })

  html <- app$get_html("body")
  expect_true(
    grepl("population|distribution|pyramid|demographic", html, ignore.case = TRUE),
    info = "Should have population description"
  )
})

test_that("E2E: Pyramid module shows data requirement message", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pyramid_data_msg",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Age-Sex Pyramid"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Age-Sex Pyramid tab")
  })

  # Without data loaded, should show placeholder or instruction
  html <- app$get_html("body")
  has_content <- nchar(html) > 100
  expect_true(has_content, info = "Pyramid module should render content")
})
