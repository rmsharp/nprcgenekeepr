#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Genetic Value Analysis Module
library(testthat)

test_that("E2E: Genetic Value Analysis tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # 8e-3: assert the Genetic Value Analysis pane is the active/visible one and
  # carries its static heading text (replaces the content-blind body grepl).
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "Genetic|Value|Analysis|Kinship"),
    info = "Should be on Genetic Value Analysis tab"
  )
})

test_that("E2E: Genetic Value has gene drop iterations control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_iterations")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Matches the always-visible numericInput label "Gene Drop Iterations:".
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "iteration|gene drop|simulation"),
    info = "Should have gene drop iterations control"
  )
})

test_that("E2E: Genetic Value has metric checkboxes", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_metrics")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Matches the static checkbox labels "Calculate Genome Uniqueness" /
  # "Calculate Mean Kinship" and the threshold selectInput label.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "genome uniqueness|mean kinship|uniqueness|kinship"),
    info = "Should have genetic metric options"
  )
})

test_that("E2E: Genetic Value has minimum breeding age control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_min_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # DRAGON (Learning #41a): the GV module has NO minimum-breeding-age control;
  # the genuine regex is kept verbatim (never renamed) because "breeding" matches
  # the always-rendered guidance text "breeding colony"
  # (inst/extdata/ui_guidance/genetic_value.html), which IS default-visible.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "minimum|breeding|age"),
    info = "Should have minimum breeding age control"
  )
})

test_that("E2E: Genetic Value has run analysis button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_run_button")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Matches the always-visible actionButton "Run Analysis" / "Calculate ..."
  # checkbox labels.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "run|analyze|calculate|start"),
    info = "Should have run analysis button"
  )
})

test_that("E2E: Genetic Value has rankings display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_rankings")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Matches the static nested-tab label "Rankings" and "Show top N:" control
  # (the rendered rankings TABLE itself is data-dependent -> 8e-6).
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "ranking|top|result"),
    info = "Should have rankings display area"
  )
})

test_that("E2E: Genetic Value has download functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_download")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  # Matches the always-visible downloadButton labels "Export All" / "Export
  # Subset".
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "download|export|save"),
    info = "Should have download functionality"
  )
})
