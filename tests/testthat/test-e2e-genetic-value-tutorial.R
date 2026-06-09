#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Genetic Value Analysis - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
library(testthat)

test_that("E2E: Genetic Value has number of simulations input", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_num_sims")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Tutorial mentions 2 to 100,000 simulations, minimum 1000 recommended.
  # Matches the static "Gene Drop Iterations:" numericInput label.
  expect_true(
    assert_active_pane(
      app, "Genetic Value Analysis",
      "simulation|iteration|numSim|number.*simulation|gene.*drop"
    ),
    info = "Should have number of simulations input"
  )
})

test_that("E2E: Genetic Value has genome uniqueness threshold", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_gu_threshold")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Tutorial mentions genome uniqueness threshold. Matches the static
  # "Genome Uniqueness Threshold:" selectInput label.
  expect_true(
    assert_active_pane(
      app, "Genetic Value Analysis",
      "genome.*uniqueness|uniqueness.*threshold|GU|threshold"
    ),
    info = "Should have genome uniqueness threshold"
  )
})

test_that("E2E: Genetic Value has Begin Analysis button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_begin_analysis")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Matches the static actionButton "Run Analysis" / "Calculate ..." labels.
  expect_true(
    assert_active_pane(
      app, "Genetic Value Analysis",
      "Begin.*Analysis|Start.*Analysis|Run.*Analysis|Analyze|Calculate"
    ),
    info = "Should have Begin Analysis button"
  )
})

test_that("E2E: Genetic Value has results table area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_results_table")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # DRAGON (Learning #41a): the rendered results table is data-dependent
  # (req(gvaView()) -> 8e-6). The genuine regex is kept verbatim: "ranking"
  # matches the always-visible "Rankings" nested-tab label.
  expect_true(
    assert_active_pane(
      app, "Genetic Value Analysis",
      "dataTable|DTOutput|table|results|ranking"
    ),
    info = "Should have results table area"
  )
})

test_that("E2E: Genetic Value mentions Value Designation", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_value_designation")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # NULL pattern (Learning #41a): Value Designation (High/Low/Undetermined) is a
  # data-dependent results concept -- it appears nowhere in the default-visible
  # static UI or guidance, so no faithful static pattern exists. Assert only that
  # the GV pane is the active/visible one; the data-bearing Value-Designation
  # assertion is deferred to 8e-6 (the real-flow slice).
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis"),
    info = "Should be on GV pane (Value Designation assertion deferred to 8e-6)"
  )
})

test_that("E2E: Genetic Value has mean kinship display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_mean_kinship")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Matches the static "Mean Kinship" labels / guidance "mean kinship".
  expect_true(
    assert_active_pane(
      app, "Genetic Value Analysis",
      "mean.*kinship|kinship.*coefficient|MK|meanKinship"
    ),
    info = "Should reference mean kinship"
  )
})

test_that("E2E: Genetic Value has Z-score display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_zscore")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # NULL pattern (Learning #41a): a z-score is a data-dependent results concept
  # absent from the static UI/guidance, so no faithful static pattern exists.
  # Assert only that the GV pane is active/visible; the data-bearing assertion is
  # deferred to 8e-6.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis"),
    info = "Should be on GV pane (Z-score assertion deferred to 8e-6)"
  )
})

test_that("E2E: Genetic Value has focal animals display option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_focal_display")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Was a tautology (expect_true(TRUE) with a dead grepl). The dead pattern's
  # "focal|display|Show.*entries|search" alternatives are foreign to the GV pane
  # (copy-paste artifacts from another module); only "filter" matches a real
  # default-visible control -- the "Filter View" button / "Filter by IDs"
  # textarea. Narrowed to "filter" per the pre-gate adversarial review.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis", "filter"),
    info = "Should have focal animals display option"
  )
})
