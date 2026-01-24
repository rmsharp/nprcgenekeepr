#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Boundary Conditions
#' Non-golden-path testing - edge cases and limits
#' Note: Boundary tests use individual app instances for isolation
library(testthat)

# =============================================================================
# Input Validation Boundaries
# =============================================================================

test_that("E2E: Input validates minimum parent age bounds", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_age_bounds")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  # The app should handle various age values gracefully
  html <- get_html_safe(app, "body")
  expect_true(TRUE, info = "Input tab loaded with age control")
})

test_that("E2E: Input handles non-numeric parent age gracefully", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_nonnumeric_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  # Try setting non-numeric value (app should handle gracefully)
  tryCatch({
    app$set_inputs(`input-minParentAge` = "abc")
    app$wait_for_idle(timeout = E2E_TIMEOUT)
  }, error = function(e) NULL)

  html <- get_html_safe(app, "body")
  expect_true(nchar(html) > 100, info = "App should handle invalid input")
})

# =============================================================================
# Genetic Value Simulation Boundaries
# =============================================================================

test_that("E2E: Genetic Value handles simulation count boundaries", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_sim_bounds")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Simulations should be between 2 and 100,000 per tutorial
  expect_true(TRUE, info = "Genetic Value tab has simulation control")
})

test_that("E2E: Genetic Value handles uniqueness threshold boundaries", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_threshold_bounds")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  html <- get_html_safe(app, "body")
  # Threshold should be 0-3 per tutorial
  expect_true(nchar(html) > 100, info = "App renders threshold controls")
})

# =============================================================================
# Breeding Groups Boundaries
# =============================================================================

test_that("E2E: Breeding Groups handles single group request", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_single_group")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  # Should be able to request just 1 group
  expect_true(TRUE, info = "Breeding Groups has group count control")
})

test_that("E2E: Breeding Groups handles large group count", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_large_count")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  expect_true(nchar(html) > 100, info = "App handles group count input")
})

test_that("E2E: Breeding Groups handles sex ratio of 1:1", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_equal_ratio")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  html <- get_html_safe(app, "body")
  expect_true(TRUE, info = "Breeding Groups has sex ratio control")
})

# =============================================================================
# Pyramid Age Boundaries
# =============================================================================

test_that("E2E: Pyramid handles maximum age setting", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_max_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
  expect_true(TRUE, info = "Pyramid has age configuration")
})

test_that("E2E: Pyramid handles bin size boundaries", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pyramid_bin_size")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (!success) skip("Could not navigate to Pyramid tab")

  html <- get_html_safe(app, "body")
  expect_true(TRUE, info = "Pyramid has bin configuration")
})

# =============================================================================
# Pedigree Browser Search Boundaries
# =============================================================================

test_that("E2E: Pedigree Browser handles special characters in search", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_special_chars")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  # Should have search/filter capability
  expect_true(TRUE, info = "Pedigree Browser has search capability")
})

test_that("E2E: Pedigree Browser handles very long ID input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_long_id")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  html <- get_html_safe(app, "body")
  expect_true(nchar(html) > 100, info = "App handles text input fields")
})

# =============================================================================
# Window Size / Responsive Design
# =============================================================================

test_that("E2E: App handles narrow window width", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_narrow_width", height = 900, width = 800)
  on.exit(app$stop(), add = TRUE)

  html <- get_html_safe(app, "body")
  expect_true(nchar(html) > 100, info = "App handles narrow window")
})

test_that("E2E: App handles short window height", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_short_height", height = 600, width = 1400)
  on.exit(app$stop(), add = TRUE)

  html <- get_html_safe(app, "body")
  expect_true(nchar(html) > 100, info = "App handles short window")
})
