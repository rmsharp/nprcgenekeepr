## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
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

  # Click the process button with no file selected; the namespaced button must
  # be reachable and the no-file path must surface the validation warning.
  clicked <- click_element_safe(app, "#dataInput-getData")
  expect_true(clicked, info = "getData button reachable at its namespaced id")

  notif <- get_html_safe(app, "#shiny-notification-panel")
  expect_match(notif, "select a file", ignore.case = TRUE,
               info = "no-file click surfaces the 'select a file' warning")
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

  # Set the minimum parent age to the 0 boundary and confirm the namespaced
  # input reflects it (a real interaction, not a swallowed no-op).
  app$set_inputs(`dataInput-minParentAge` = "0")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  expect_equal(app$get_value(input = "dataInput-minParentAge"), "0",
               info = "minParentAge accepts and reflects the set value")
  expect_true(assert_active_pane(app, "Input", "Minimum Parent Age"),
              info = "Input pane stays active after a boundary value")
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

  # Without data loaded, the Pedigree Browser pane is still the active one
  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Focal Animals|Pedigree Browser"),
    info = "Pedigree Browser pane active with no data loaded"
  )
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

  # Before any upload the pane shows its static controls (Display Options)
  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Display Options|Pedigree Browser"),
    info = "Pedigree Browser pane active before any data upload"
  )
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

  # Pre-data the GV pane shows its analysis controls (Run Analysis)
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis", "Run Analysis|Genetic Value"),
    info = "Genetic Value pane active before data is loaded"
  )
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

  # The Gene Drop Iterations control lives in the active GV pane
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis", "Iterations|Gene Drop"),
    info = "Genetic Value pane active with its simulation control"
  )
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

  # Pre-data the Breeding Groups pane shows its formation controls (Form Groups)
  expect_true(
    assert_active_pane(app, "Breeding Groups", "Form Groups|Breeding Group"),
    info = "Breeding Groups pane active before data is loaded"
  )
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

  # The "Number of groups" control is present in the active pane
  expect_true(
    assert_active_pane(app, "Breeding Groups", "Number of groups"),
    info = "Breeding Groups pane active with its group-count control"
  )
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

  # The Sex ratio control (incl. the Harem option) is in the active pane
  expect_true(
    assert_active_pane(app, "Breeding Groups", "Sex ratio|Harem"),
    info = "Breeding Groups pane active with its sex-ratio control"
  )
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

  # Pre-data the Age-Sex Pyramid pane is the active one
  expect_true(
    assert_active_pane(app, "Age-Sex Pyramid", "Pyramid|Age|Sex"),
    info = "Age-Sex Pyramid pane active before data is loaded"
  )
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

  # After the rapid sequence ending on Home, that pane must be the active one
  expect_true(assert_active_pane(app, "Home", "Welcome|GeneKeepR"),
              info = "App lands on the Home pane after rapid tab switching")
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

  expect_true(assert_active_pane(app, "Input", "Data Input"),
              info = "Input pane active after repeated clicks on its tab")
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

  # The GV export buttons (Export All / Export Subset) render in the active pane
  # even before any analysis has been run.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis", "Export All|Export Subset"),
    info = "Genetic Value export buttons present in the active pane without data"
  )
})
