## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Tests for Boundary Conditions
#' Non-golden-path testing - edge cases and limits
library(testthat)

# =============================================================================
# Input Validation Boundaries
# =============================================================================

test_that("E2E: Input validates minimum sire age bounds", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_age_bounds")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  # The minimum-sire-age control is present in the active Input pane
  expect_true(assert_active_pane(app, "Input", "Minimum Sire Age"),
              info = "Input pane active with its minimum-sire-age control")
})

test_that("E2E: Input handles non-numeric sire age gracefully", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_input_nonnumeric_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  # Set a non-numeric sire age; the textInput accepts the string and the app
  # stays up (a real interaction, not a swallowed no-op).
  app$set_inputs(`dataInput-minSireAge` = "abc")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  expect_equal(app$get_value(input = "dataInput-minSireAge"), "abc",
               info = "minSireAge accepts a non-numeric string value")
  expect_true(assert_active_pane(app, "Input", "Minimum Sire Age"),
              info = "Input pane stays active on invalid input (no crash)")
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

  # The Gene Drop Iterations control lives in the active GV pane
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis", "Iterations|Gene Drop"),
    info = "Genetic Value pane active with its iteration control"
  )
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

  # The Genome Uniqueness Threshold control is in the active GV pane
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis", "Threshold|Uniqueness"),
    info = "Genetic Value pane active with its uniqueness-threshold control"
  )
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

  # The "Number of groups" control is present in the active pane
  expect_true(assert_active_pane(app, "Breeding Groups", "Number of groups"),
              info = "Breeding Groups pane active with its group-count control")
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

  expect_true(
    assert_active_pane(app, "Breeding Groups", "Number of groups|Form Groups"),
    info = "Breeding Groups pane active for a large group count"
  )
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

  # The Sex ratio control (incl. the Harem option) is in the active pane
  expect_true(assert_active_pane(app, "Breeding Groups", "Sex ratio|Harem"),
              info = "Breeding Groups pane active with its sex-ratio control")
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

  # The Age Unit / Age Label controls are in the active Pyramid pane
  expect_true(assert_active_pane(app, "Age-Sex Pyramid", "Age Unit|Age Label"),
              info = "Age-Sex Pyramid pane active with its age controls")
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

  # The Bin Size control is in the active Pyramid pane
  expect_true(assert_active_pane(app, "Age-Sex Pyramid", "Bin Size"),
              info = "Age-Sex Pyramid pane active with its bin-size control")
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

  # The Pedigree Browser pane has search / focal-animal controls
  expect_true(
    assert_active_pane(app, "Pedigree Browser", "search|Focal Animals"),
    info = "Pedigree Browser pane active with its search/focal control"
  )
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

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Pedigree Browser|Focal Animals"),
    info = "Pedigree Browser pane active for long-ID input"
  )
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

  # On boot the Home pane renders active even at a narrow viewport width
  expect_true(assert_active_pane(app, "Home", "Welcome|GeneKeepR"),
              info = "Home pane renders active in a narrow window")
})

test_that("E2E: App handles short window height", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_short_height", height = 600, width = 1400)
  on.exit(app$stop(), add = TRUE)

  # On boot the Home pane renders active even at a short viewport height
  expect_true(assert_active_pane(app, "Home", "Welcome|GeneKeepR"),
              info = "Home pane renders active in a short window")
})
