#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Summary Statistics Module
#' Based on ColonyManagerTutorial.Rmd workflow
#'
#' Phase 8e-1 (GitHub issue #40): converted from boot-level tautologies
#' (expect_true(TRUE) reached after a WRONG-tab navigation to "Genetic Value
#' Analysis") into behavioral active-pane assertions. Each test now navigates to
#' the real "Summary Statistics" tab and asserts, via assert_active_pane(), that
#' THAT pane is the single visible/active one AND contains the expected STATIC UI
#' (export-button labels, the heading, the population-genetics guidance). The
#' data-bearing content (the summary/quartile/founder tables and the rendered
#' plots, which require a Genetic Value Analysis run) is deferred to slice 8e-6.
#' See the active-pane helpers in helper-shinytest2.R.
library(testthat)

test_that("E2E: Summary Statistics tab is accessible and active", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")

  expect_true(
    assert_active_pane(app, "Summary Statistics", "Summary Statistics and Plots"),
    info = "Summary Statistics pane should be active and show its heading"
  )
})

test_that("E2E: Summary Statistics has Export Kinship Matrix button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_kinship_export")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")

  expect_true(
    assert_active_pane(app, "Summary Statistics", "Export Kinship Matrix"),
    info = "Active Summary Statistics pane should expose the Export Kinship Matrix control"
  )
})

test_that("E2E: Summary Statistics has First-Order Relationships export", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_firstorder")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")

  expect_true(
    assert_active_pane(app, "Summary Statistics", "Export First-Order Relationships"),
    info = "Active Summary Statistics pane should expose the First-Order Relationships export"
  )
})

test_that("E2E: Summary Statistics has Male Founders export", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_male_founders")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")

  expect_true(
    assert_active_pane(app, "Summary Statistics", "Export Male Founders"),
    info = "Active Summary Statistics pane should expose the Export Male Founders control"
  )
})

test_that("E2E: Summary Statistics has Female Founders export", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_female_founders")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")

  expect_true(
    assert_active_pane(app, "Summary Statistics", "Export Female Founders"),
    info = "Active Summary Statistics pane should expose the Export Female Founders control"
  )
})

test_that("E2E: Summary Statistics has histogram plots area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_histograms")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")

  # The plotOutput placeholders are empty pre-data, but their export controls
  # ("Export Mean Kinship Histogram", etc.) are static UI in the active pane.
  expect_true(
    assert_active_pane(app, "Summary Statistics", "Histogram"),
    info = "Active Summary Statistics pane should expose histogram export controls"
  )
})

test_that("E2E: Summary Statistics has boxplot plots area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_boxplots")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")

  # Box-plot export controls ("Export Mean Kinship Box Plot", etc.) are static
  # UI in the active pane (the plots themselves render only after a GVA run).
  expect_true(
    assert_active_pane(app, "Summary Statistics", "Box Plot"),
    info = "Active Summary Statistics pane should expose box-plot export controls"
  )
})

test_that("E2E: Summary Statistics has founder equivalents info", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ss_founder_equiv")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")

  # The founder-equivalents TABLE is data-dependent (deferred to 8e-6), but the
  # population-genetics guidance HTML at the bottom of the pane statically
  # defines "Founder Equivalents" / "Founder Genome Equivalents".
  expect_true(
    assert_active_pane(app, "Summary Statistics",
                       "founder.*equivalent|genome.*equivalent"),
    info = "Active Summary Statistics pane should define founder/genome equivalents"
  )
})
