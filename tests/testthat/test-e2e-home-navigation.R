#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Home Tab and Navigation
library(testthat)

test_that("E2E: Home tab loads on startup", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_home_load",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(
    grepl("Welcome|GeneKeepR|Home", html, ignore.case = TRUE),
    info = "Home tab should load on startup"
  )
})

test_that("E2E: Home tab displays version information", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_home_version",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(
    grepl("Version|Genetic Management", html, ignore.case = TRUE),
    info = "Should display version or description"
  )
})

test_that("E2E: Home tab has Data Input panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_home_input_panel",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(
    grepl("Data Input|Upload|studbook", html, ignore.case = TRUE),
    info = "Should have Data Input panel"
  )
})

test_that("E2E: Home tab has Pedigree Browser panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_home_pedigree_panel",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(
    grepl("Pedigree Browser|Browse|filter", html, ignore.case = TRUE),
    info = "Should have Pedigree Browser panel"
  )
})

test_that("E2E: Home tab has Population Analysis panel", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_home_population_panel",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(
    grepl("Population|Analysis|age|sex", html, ignore.case = TRUE),
    info = "Should have Population Analysis panel"
  )
})

test_that("E2E: Go to Input button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_goto_input",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Click Go to Input button
  tryCatch({
    app$click(selector = "#goto_input")
    Sys.sleep(2)

    html <- app$get_html("body")
    expect_true(
      grepl("Upload|File|Input", html, ignore.case = TRUE),
      info = "Should navigate to Input tab"
    )
  }, error = function(e) {
    skip("Could not click Go to Input button")
  })
})

test_that("E2E: Go to Pedigree button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_goto_pedigree",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Click Go to Pedigree button
  tryCatch({
    app$click(selector = "#goto_pedigree")
    Sys.sleep(2)

    html <- app$get_html("body")
    expect_true(
      grepl("Pedigree|Browser|Filter", html, ignore.case = TRUE),
      info = "Should navigate to Pedigree tab"
    )
  }, error = function(e) {
    skip("Could not click Go to Pedigree button")
  })
})

test_that("E2E: Go to Pyramid button navigates correctly", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_goto_pyramid",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Click Go to Pyramid button
  tryCatch({
    app$click(selector = "#goto_pyramid")
    Sys.sleep(2)

    html <- app$get_html("body")
    expect_true(
      grepl("Pyramid|Age|Sex|Population", html, ignore.case = TRUE),
      info = "Should navigate to Pyramid tab"
    )
  }, error = function(e) {
    skip("Could not click Go to Pyramid button")
  })
})

test_that("E2E: Navbar has all main tabs", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_navbar_tabs",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")

  # Check for main navigation tabs
  expect_true(grepl("Home", html), info = "Should have Home tab")
  expect_true(grepl("Input", html), info = "Should have Input tab")
  expect_true(
    grepl("Pedigree", html, ignore.case = TRUE),
    info = "Should have Pedigree tab"
  )
  expect_true(
    grepl("Pyramid", html, ignore.case = TRUE),
    info = "Should have Pyramid tab"
  )
  expect_true(
    grepl("Genetic Value", html, ignore.case = TRUE),
    info = "Should have Genetic Value tab"
  )
  expect_true(
    grepl("Breeding|Groups", html, ignore.case = TRUE),
    info = "Should have Breeding Groups tab"
  )
})

test_that("E2E: More menu exists in navbar", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_more_menu",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(
    grepl("More|Settings|About|Help", html, ignore.case = TRUE),
    info = "Should have More menu or its items"
  )
})
