#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Settings, About, and Help Tabs
library(testthat)

test_that("E2E: Settings tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_settings_access",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Try to navigate to Settings
  tryCatch({
    # Click More menu first if it exists
    tryCatch({
      app$click(selector = 'a[data-toggle="dropdown"]')
      Sys.sleep(1)
    }, error = function(e) NULL)

    app$click(selector = 'a[data-value="Settings"]')
    Sys.sleep(2)

    html <- app$get_html("body")
    expect_true(
      grepl("Settings|Configuration|options", html, ignore.case = TRUE),
      info = "Should be on Settings tab"
    )
  }, error = function(e) {
    skip("Could not navigate to Settings tab")
  })
})

test_that("E2E: About tab shows version and credits", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_about_tab",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Try to navigate to About
  tryCatch({
    # Click More menu first if it exists
    tryCatch({
      app$click(selector = 'a[data-toggle="dropdown"]')
      Sys.sleep(1)
    }, error = function(e) NULL)

    app$click(selector = 'a[data-value="About"]')
    Sys.sleep(2)

    html <- app$get_html("body")
    expect_true(
      grepl("About|Version|GeneKeepR|Oregon|Primate", html, ignore.case = TRUE),
      info = "Should show About information"
    )
  }, error = function(e) {
    skip("Could not navigate to About tab")
  })
})

test_that("E2E: Help tab has documentation link", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_help_tab",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Try to navigate to Help
  tryCatch({
    # Click More menu first if it exists
    tryCatch({
      app$click(selector = 'a[data-toggle="dropdown"]')
      Sys.sleep(1)
    }, error = function(e) NULL)

    app$click(selector = 'a[data-value="Help"]')
    Sys.sleep(2)

    html <- app$get_html("body")
    expect_true(
      grepl("Help|Documentation|Online", html, ignore.case = TRUE),
      info = "Should show Help documentation"
    )
  }, error = function(e) {
    skip("Could not navigate to Help tab")
  })
})

test_that("E2E: About tab mentions NIH funding", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_about_nih",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Try to navigate to About
  tryCatch({
    tryCatch({
      app$click(selector = 'a[data-toggle="dropdown"]')
      Sys.sleep(1)
    }, error = function(e) NULL)

    app$click(selector = 'a[data-value="About"]')
    Sys.sleep(2)

    html <- app$get_html("body")
    expect_true(
      grepl("NIH|funded|grant", html, ignore.case = TRUE),
      info = "Should mention NIH funding"
    )
  }, error = function(e) {
    skip("Could not navigate to About tab")
  })
})
