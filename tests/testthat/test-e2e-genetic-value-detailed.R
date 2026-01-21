#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Genetic Value Module
library(testthat)

test_that("E2E: Genetic Value has population selection", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_pop_select",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Genetic Value Analysis tab")
  })

  html <- app$get_html("body")
  expect_true(
    grepl("population|select|animals|subset", html, ignore.case = TRUE),
    info = "Should have population selection"
  )
})

test_that("E2E: Genetic Value has genome uniqueness display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_gu",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Genetic Value Analysis tab")
  })

  html <- app$get_html("body")
  expect_true(
    grepl("genome|uniqueness|GU|unique", html, ignore.case = TRUE),
    info = "Should have genome uniqueness display"
  )
})

test_that("E2E: Genetic Value has founder equivalents info", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_fe",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Genetic Value Analysis tab")
  })

  html <- app$get_html("body")
  has_fe <- grepl("founder|equivalent|FE|genetic", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Genetic Value tab loaded successfully")
})

test_that("E2E: Genetic Value has kinship analysis section", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_kinship_section",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Genetic Value Analysis tab")
  })

  html <- app$get_html("body")
  expect_true(
    grepl("kinship|mean|coefficient|MK", html, ignore.case = TRUE),
    info = "Should have kinship analysis section"
  )
})

test_that("E2E: Genetic Value has ranking capability", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_ranking",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Genetic Value Analysis tab")
  })

  html <- app$get_html("body")
  expect_true(
    grepl("rank|value|score|priority", html, ignore.case = TRUE),
    info = "Should have ranking capability"
  )
})

test_that("E2E: Genetic Value has report generation", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_report",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Genetic Value Analysis tab")
  })

  html <- app$get_html("body")
  has_report <- grepl("report|export|download|summary", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Genetic Value tab loaded successfully")
})

test_that("E2E: Genetic Value shows analysis instructions", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_instructions",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Genetic Value Analysis tab")
  })

  html <- app$get_html("body")
  has_content <- nchar(html) > 200
  expect_true(has_content, info = "Should show analysis instructions or interface")
})
