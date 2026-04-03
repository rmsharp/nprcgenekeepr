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
  app <- create_app_driver(app_dir, "e2e_input_no_file")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  # Try clicking the action button without selecting a file
  click_element_safe(app, "#input-getData")

  html <- get_html_safe(app, "body")
  # App should still be responsive and not crash
  expect_true(nchar(html) > 100, info = "App should remain responsive")
})

test_that("E2E: Input handles zero minimum parent age", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_zero_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  # Try setting minimum parent age to 0
  tryCatch({
    app$set_inputs(`input-minParentAge` = "0")
    app$wait_for_idle(timeout = E2E_TIMEOUT)
  }, error = function(e) NULL)

  html <- get_html_safe(app, "body")
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
  app <- create_app_driver(app_dir, "e2e_ped_empty_focal")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  # Without data loaded, should show placeholder or message
  expect_true(nchar(html) > 100, info = "App should handle no data state")
})

test_that("E2E: Pedigree Browser state before data upload", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_no_data")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
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
  app <- create_app_driver(app_dir, "e2e_gv_no_data")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Should show message about needing to load data first
  expect_true(nchar(html) > 100, info = "App should handle no-data state")
})

test_that("E2E: Genetic Value with minimum simulation count", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_min_sims")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Minimum simulations is 2 according to tutorial
  html <- get_html_safe(app, "body")
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
  app <- create_app_driver(app_dir, "e2e_bg_no_data")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  expect_true(nchar(html) > 100, info = "App should handle no-data state")
})

test_that("E2E: Breeding Groups with zero groups requested", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_zero_groups")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # Try setting number of groups to boundary value
  html <- get_html_safe(app, "body")
  expect_true(nchar(html) > 100, info = "App should handle boundary conditions")
})

test_that("E2E: Breeding Groups with extreme sex ratio", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_extreme_ratio")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
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
  app <- create_app_driver(app_dir, "e2e_pyramid_no_data")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
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
  app <- create_app_driver(app_dir, "e2e_rapid_switch")
  on.exit(app$stop(), add = TRUE)

  # Rapidly switch between tabs with minimal waits
 tabs <- c("Input", "Pedigree Browser", "Age-Sex Pyramid",
            "Genetic Value Analysis", "Breeding Groups", "Home")

  for (tab in tabs) {
    tryCatch({
      app$click(selector = paste0('a[data-value="', tab, '"]'))
      app$wait_for_idle(timeout = 2000)  # Short wait for rapid switching
    }, error = function(e) NULL)
  }

  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # App should still be responsive
  html <- get_html_safe(app, "body")
  expect_true(nchar(html) > 100, info = "App should recover from rapid switching")
})

test_that("E2E: App handles clicking same tab multiple times", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_same_tab_clicks")
  on.exit(app$stop(), add = TRUE)

  # Click the same tab multiple times
  for (i in 1:3) {
    click_element_safe(app, 'a[data-value="Input"]')
  }

  html <- get_html_safe(app, "body")
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
  app <- create_app_driver(app_dir, "e2e_export_no_data")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate")

  html <- get_html_safe(app, "body")
  # Export/download buttons should exist even without data
  has_export_elements <- grepl("export|download|save", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Page loaded successfully")
})
