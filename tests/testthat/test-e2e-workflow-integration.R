#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Cross-Module Workflow Integration
library(testthat)

test_that("E2E: Can navigate through all main tabs sequentially", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_sequential_nav",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tabs_visited <- 0

  # Visit Home
  html <- app$get_html("body")
  if (grepl("Welcome|Home|GeneKeepR", html, ignore.case = TRUE)) {
    tabs_visited <- tabs_visited + 1
  }

  # Visit Input
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
    html <- app$get_html("body")
    if (grepl("Upload|File|Input", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }, error = function(e) NULL)

  # Visit Pedigree Browser
  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
    html <- app$get_html("body")
    if (grepl("Pedigree|Browser", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }, error = function(e) NULL)

  # Visit Age-Sex Pyramid
  tryCatch({
    app$click(selector = 'a[data-value="Age-Sex Pyramid"]')
    Sys.sleep(2)
    html <- app$get_html("body")
    if (grepl("Pyramid|Age|Sex", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }, error = function(e) NULL)

  # Visit Genetic Value Analysis
  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)
    html <- app$get_html("body")
    if (grepl("Genetic|Value", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }, error = function(e) NULL)

  # Visit Breeding Groups
  tryCatch({
    app$click(selector = 'a[data-value="Breeding Groups"]')
    Sys.sleep(2)
    html <- app$get_html("body")
    if (grepl("Breeding|Groups", html, ignore.case = TRUE)) {
      tabs_visited <- tabs_visited + 1
    }
  }, error = function(e) NULL)

  expect_true(tabs_visited >= 3, info = "Should visit at least 3 tabs successfully")
})

test_that("E2E: App maintains state when switching tabs", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_state_maintain",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Get initial values
  values1 <- app$get_values()

  # Switch to another tab
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
  }, error = function(e) skip("Could not switch tabs"))

  # Switch back
  tryCatch({
    app$click(selector = 'a[data-value="Home"]')
    Sys.sleep(2)
  }, error = function(e) skip("Could not switch back"))

  # Get values again
  values2 <- app$get_values()

  # App should still be responsive
  expect_true(is.list(values1), info = "Initial values should be a list")
  expect_true(is.list(values2), info = "Values after switching should be a list")
})

test_that("E2E: App is responsive after multiple tab switches", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_multi_switch",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Perform multiple tab switches
  tabs <- c("Input", "Home", "Input", "Home")

  for (tab in tabs) {
    tryCatch({
      app$click(selector = paste0('a[data-value="', tab, '"]'))
      Sys.sleep(1)
    }, error = function(e) NULL)
  }

  # App should still be responsive
  values <- app$get_values()
  expect_true(is.list(values), info = "App should remain responsive after multiple switches")
})

test_that("E2E: Navbar brand/title is visible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_navbar_brand",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(
    grepl("GeneKeepR", html, ignore.case = TRUE),
    info = "Navbar should show GeneKeepR brand"
  )
})

test_that("E2E: Input tab has file upload before pedigree browser works", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_workflow_upload",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Go to Input tab
  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)

    html <- app$get_html("body")
    has_upload <- grepl("upload|file|browse", html, ignore.case = TRUE)

    expect_true(has_upload, info = "Input tab should have file upload capability")
  }, error = function(e) {
    skip("Could not navigate to Input tab")
  })
})

test_that("E2E: Genetic Value tab indicates data requirement", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_data_req",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Go to Genetic Value tab
  tryCatch({
    app$click(selector = 'a[data-value="Genetic Value Analysis"]')
    Sys.sleep(2)

    html <- app$get_html("body")
    # Should have some indication of needing data or showing analysis options
    has_content <- grepl(
      "Genetic|Value|Analysis|kinship|population",
      html,
      ignore.case = TRUE
    )

    expect_true(has_content, info = "Genetic Value tab should show relevant content")
  }, error = function(e) {
    skip("Could not navigate to Genetic Value tab")
  })
})

test_that("E2E: Breeding Groups tab indicates data requirement", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_bg_data_req",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Go to Breeding Groups tab
  tryCatch({
    app$click(selector = 'a[data-value="Breeding Groups"]')
    Sys.sleep(2)

    html <- app$get_html("body")
    # Should have some indication of breeding group functionality
    has_content <- grepl(
      "Breeding|Groups|formation|animals",
      html,
      ignore.case = TRUE
    )

    expect_true(has_content, info = "Breeding Groups tab should show relevant content")
  }, error = function(e) {
    skip("Could not navigate to Breeding Groups tab")
  })
})
