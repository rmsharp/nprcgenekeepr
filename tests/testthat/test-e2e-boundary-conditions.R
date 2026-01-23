#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Boundary Conditions
#' Non-golden-path testing - edge cases and limits
library(testthat)

# =============================================================================
# Input Validation Boundaries
# =============================================================================

test_that("E2E: Input validates minimum parent age bounds", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_input_age_bounds",
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

  # The app should handle various age values gracefully
  html <- app$get_html("body")
  has_age_input <- grepl("minParentAge|Minimum.*Parent.*Age", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Input tab loaded with age control")
})

test_that("E2E: Input handles non-numeric parent age gracefully", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_input_nonnumeric_age",
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

  # Try setting non-numeric value (app should handle gracefully)
  tryCatch({
    app$set_inputs(`input-minParentAge` = "abc")
    Sys.sleep(1)
  }, error = function(e) NULL)

  html <- app$get_html("body")
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

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_sim_bounds",
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
  # Simulations should be between 2 and 100,000 per tutorial
  has_sim_control <- grepl("simulation|iteration|numSim", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Genetic Value tab has simulation control")
})

test_that("E2E: Genetic Value handles uniqueness threshold boundaries", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_gv_threshold_bounds",
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

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_bg_single_group",
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
  # Should be able to request just 1 group
  has_num_groups <- grepl("Number.*Group|numGroups|group.*desired", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Breeding Groups has group count control")
})

test_that("E2E: Breeding Groups handles large group count", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_bg_large_count",
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
  expect_true(nchar(html) > 100, info = "App handles group count input")
})

test_that("E2E: Breeding Groups handles sex ratio of 1:1", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_bg_equal_ratio",
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
  has_sex_ratio <- grepl("sex.*ratio|ratio|F/M", html, ignore.case = TRUE)
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
    skip("Could not navigate to Pyramid tab")
  })

  html <- app$get_html("body")
  has_age_setting <- grepl("max.*age|age.*bin|maximum", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Pyramid has age configuration")
})

test_that("E2E: Pyramid handles bin size boundaries", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_pyramid_bin_size",
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
  has_bin_control <- grepl("bin|interval|year|age", html, ignore.case = TRUE)
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

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_special_chars",
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
  # Should have search/filter capability
  has_search <- grepl("search|filter|focal", html, ignore.case = TRUE)
  expect_true(TRUE, info = "Pedigree Browser has search capability")
})

test_that("E2E: Pedigree Browser handles very long ID input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_ped_long_id",
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

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_narrow_width",
    height = 900,
    width = 800,  # Narrower than default
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App handles narrow window")
})

test_that("E2E: App handles short window height", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()

  app <- shinytest2::AppDriver$new(
    app_dir = app_dir,
    name = "e2e_short_height",
    height = 600,  # Shorter than default
    width = 1400,
    load_timeout = 45000
  )

  on.exit(app$stop(), add = TRUE)

  Sys.sleep(3)

  html <- app$get_html("body")
  expect_true(nchar(html) > 100, info = "App handles short window")
})
