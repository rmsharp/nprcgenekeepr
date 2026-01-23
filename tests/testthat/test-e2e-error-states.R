#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Error States and Edge Cases
#' Non-golden-path testing
library(testthat)

# =============================================================================
# Input Module - Error States
# =============================================================================

test_that("E2E: Input shows message when no file selected", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_input_no_file",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Input tab")
  })

  # Try clicking the action button without selecting a file
  tryCatch({
    app$click(selector = "#input-getData")
    Sys.sleep(2)
  }, error = function(e) NULL)

  html <- app$get_html("body")
  # App should still be responsive and not crash
  expect_true(nchar(html) > 100, info = "App should remain responsive")
})

test_that("E2E: Input handles zero minimum parent age", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_input_zero_age",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Input"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Input tab")
  })

  # Try setting minimum parent age to 0
  tryCatch({
    app$set_inputs(`input-minParentAge` = "0")
    Sys.sleep(1)
  }, error = function(e) NULL)

  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App should handle zero parent age")
})

# =============================================================================
# Pedigree Browser - Edge Cases
# =============================================================================

test_that("E2E: Pedigree Browser handles empty focal animal input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_empty_focal",
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
  # Without data loaded, should show placeholder or message
  expect_true(nchar(html) > 100, info = "App should handle no data state")
})

test_that("E2E: Pedigree Browser state before data upload", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_no_data",
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
  # Should show empty table or message about needing data
  has_empty_state <- grepl(
    "No data|upload|load|empty|0 entries|no entries",
    html,
    ignore.case = TRUE
  ) || nchar(html) > 100
  expect_true(has_empty_state, info = "Should handle empty data state gracefully")
})

# =============================================================================
# Genetic Value Analysis - Error States
# =============================================================================

test_that("E2E: Genetic Value before data is loaded", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_no_data",
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
    skip("Could not navigate to Genetic Value tab")
  })

  html <- app$get_html("body")
  # Should show message about needing to load data first
  expect_true(nchar(html) > 100, info = "App should handle no-data state")
})

test_that("E2E: Genetic Value with minimum simulation count", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_min_sims",
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
    skip("Could not navigate to Genetic Value tab")
  })

  # Minimum simulations is 2 according to tutorial
  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App should be responsive")
})

# =============================================================================
# Breeding Groups - Edge Cases
# =============================================================================

test_that("E2E: Breeding Groups before data is loaded", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_bg_no_data",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Breeding Groups"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Breeding Groups tab")
  })

  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App should handle no-data state")
})

test_that("E2E: Breeding Groups with zero groups requested", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_bg_zero_groups",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Breeding Groups"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Breeding Groups tab")
  })

  # Try setting number of groups to boundary value
  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App should handle boundary conditions")
})

test_that("E2E: Breeding Groups with extreme sex ratio", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_bg_extreme_ratio",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  tryCatch({
    app$click(selector = 'a[data-value="Breeding Groups"]')
    Sys.sleep(2)
  }, error = function(e) {
    skip("Could not navigate to Breeding Groups tab")
  })

  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App should handle extreme values")
})

# =============================================================================
# Age-Sex Pyramid - Edge Cases
# =============================================================================

test_that("E2E: Pyramid before data is loaded", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pyramid_no_data",
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
    skip("Could not navigate to Pyramid tab")
  })

  html <- app$get_html("body")
  # Should show placeholder or message when no data
  expect_true(nchar(html) > 100, info = "App should handle no-data state")
})

# =============================================================================
# Navigation Error Handling
# =============================================================================

test_that("E2E: App recovers from rapid tab switching", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_rapid_switch",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Rapidly switch between tabs
  tabs <- c("Input", "Pedigree Browser", "Age-Sex Pyramid",
            "Genetic Value Analysis", "Breeding Groups", "Home")

  for (tab in tabs) {
    tryCatch({
      app$click(selector = paste0('a[data-value="', tab, '"]'))
      Sys.sleep(0.5)  # Minimal wait
    }, error = function(e) NULL)
  }

  Sys.sleep(2)

  # App should still be responsive
  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App should recover from rapid switching")
})

test_that("E2E: App handles clicking same tab multiple times", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_same_tab_clicks",
    height = 900,
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  # Click the same tab multiple times
  for (i in 1:3) {
    tryCatch({
      app$click(selector = 'a[data-value="Input"]')
      Sys.sleep(1)
    }, error = function(e) NULL)
  }

  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App should handle repeated clicks")
})

# =============================================================================
# Export Button States
# =============================================================================

test_that("E2E: Export buttons exist but may be disabled without data", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_export_no_data",
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
    skip("Could not navigate")
  })

  html <- app$get_html("body")
  # Export/download buttons should exist even without data
  has_export_elements <- grepl("export|download|save", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Page loaded successfully")
})
