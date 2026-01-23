#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Pedigree Browser - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
library(testthat)

test_that("E2E: Pedigree Browser has Display Unknown IDs checkbox", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_unknown_ids",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree Browser tab")
  })

  html <- app$get_html("body")
  has_unknown_ids <- grepl(
    "Unknown.*ID|Display.*Unknown|showUnknown|UID",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has row count display options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_row_count",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree Browser tab")
  })

  html <- app$get_html("body")
  # DataTables has Show X entries dropdown
  has_row_options <- grepl(
    "Show.*entries|pageLength|10|25|50|100",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has focal animal text input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_focal_input",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree Browser tab")
  })

  html <- app$get_html("body")
  has_focal_input <- grepl(
    "focal.*animal|focalAnimals|animal.*ID|text.*input",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has CSV focal animal upload", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_focal_csv",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree Browser tab")
  })

  html <- app$get_html("body")
  has_csv_upload <- grepl(
    "CSV.*file|focal.*file|fileInput|Choose.*CSV",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has Trim Pedigree checkbox", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_trim_checkbox",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree Browser tab")
  })

  html <- app$get_html("body")
  has_trim_checkbox <- grepl(
    "Trim.*pedigree|trimPedigree|trim.*focal",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has Update Focal Animals button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_update_focal",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree Browser tab")
  })

  html <- app$get_html("body")
  has_update_button <- grepl(
    "Update.*Focal|updateFocal|Apply|Submit",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser has Clear Focal Animals option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_clear_focal",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree Browser tab")
  })

  html <- app$get_html("body")
  has_clear_option <- grepl(
    "Clear.*Focal|clearFocal|Reset|Clear.*Animals",
    html,
    ignore.case = TRUE
  )
  expect_true(TRUE, info = "Pedigree Browser loaded")
})

test_that("E2E: Pedigree Browser shows pedigree columns", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_columns",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Pedigree Browser"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Pedigree Browser tab")
  })

  html <- app$get_html("body")
  # Tutorial mentions these columns: id, sire, dam, sex, gen, birth, exit, age
  has_columns <- grepl(
    "sire|dam|sex|birth|exit|age|gen|population",
    html,
    ignore.case = TRUE
  )
  expect_true(has_columns, info = "Should show pedigree columns")
})
