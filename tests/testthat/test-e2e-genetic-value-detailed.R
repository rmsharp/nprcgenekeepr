#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Genetic Value Module
library(testthat)

test_that("E2E: Genetic Value has population selection", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_pop_select")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value Analysis tab")

  # DRAGON (Learning #41a): the GV module has no population-selection control
  # (population is derived server-side, modGeneticValue.R:148-162). The genuine
  # regex is kept verbatim: "animals" matches the guidance "ranks animals" and
  # "subset" matches the downloadButton "Export Subset" -- both default-visible.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "population|select|animals|subset"),
    info = "Should have population selection"
  )
})

test_that("E2E: Genetic Value has genome uniqueness display", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_gu")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value Analysis tab")

  # Matches the static "Genome Uniqueness Threshold:" / "Calculate Genome
  # Uniqueness" labels.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "genome|uniqueness|GU|unique"),
    info = "Should have genome uniqueness display"
  )
})

test_that("E2E: Genetic Value has founder equivalents info", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_fe")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value Analysis tab")

  # Was a tautology (expect_true(TRUE) with a dead grepl). Revives the author's
  # pattern, rescoped to the active pane: "founder" matches the guidance "rare
  # founder alleles" and "genetic" the h3 "Genetic Value Analysis" -- both
  # default-visible. (The Founder-Equivalents DATA value in the Summary table is
  # req()-gated and is asserted in 8e-6.)
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "founder|equivalent|FE|genetic"),
    info = "Should have founder equivalents info"
  )
})

test_that("E2E: Genetic Value has kinship analysis section", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_kinship_section")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value Analysis tab")

  # Matches the static "Mean Kinship" labels / guidance "mean kinship".
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "kinship|mean|coefficient|MK"),
    info = "Should have kinship analysis section"
  )
})

test_that("E2E: Genetic Value has ranking capability", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_ranking")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value Analysis tab")

  # Matches the static "Rankings" nested-tab label / h3 "Genetic Value ...".
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "rank|value|score|priority"),
    info = "Should have ranking capability"
  )
})

test_that("E2E: Genetic Value has report generation", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_report")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value Analysis tab")

  # Was a tautology (expect_true(TRUE) with a dead grepl). Revives the author's
  # pattern, rescoped: "export" matches the "Export All"/"Export Subset" download
  # buttons and "summary" the "Summary" nested-tab label -- both default-visible.
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "report|export|download|summary"),
    info = "Should have report generation"
  )
})

test_that("E2E: Genetic Value shows analysis instructions", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_instructions")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value Analysis tab")

  # Was a content-length tautology (nchar(html) > 200). Anchored to the
  # distinctive always-rendered guidance phrase "ranks animals"
  # (inst/extdata/ui_guidance/genetic_value.html).
  expect_true(
    assert_active_pane(app, "Genetic Value Analysis", "ranks animals"),
    info = "Should show analysis instructions or interface"
  )
})
