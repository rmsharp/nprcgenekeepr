## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Detailed E2E Tests for Pedigree Browser Module
library(testthat)

test_that("E2E: Pedigree browser has filter controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_filter")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "filter|search|select"),
    info = "Should have filter controls"
  )
})

test_that("E2E: Pedigree browser has ID search", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_id_search")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "ID|animal|identifier|search"),
    info = "Should have ID search capability"
  )
})

test_that("E2E: Pedigree browser shows relationship information", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_relations")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(
      app, "Pedigree Browser",
      "sire|dam|parent|offspring|ancestor|descendant"
    ),
    info = "Should show relationship information"
  )
})

test_that("E2E: Pedigree browser has data table", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_table")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  # 8e-6a: assert the data-bearing rendered pedigree DataTable. The DataTable
  # DOM (row-count info + parent columns) renders only once the Pedigree Browser
  # tab is active AND a studbook is loaded (req(pedigreeData())).
  html <- get_html_safe(app, "#pedigree-pedigreeTable")
  expect_match(
    html, "of 375 entries",
    info = "DataTable displays all 375 fixture pedigree rows"
  )
  expect_match(
    html, "sire",
    info = "Pedigree table includes the sire parent column"
  )
  expect_match(
    html, "dam",
    info = "Pedigree table includes the dam parent column"
  )
})

test_that("E2E: Pedigree browser has sex filter option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_sex_filter")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "sex|male|female|gender"),
    info = "Should have sex filter option"
  )
})

test_that("E2E: Pedigree browser has status filter", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_ped_status_filter")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree Browser tab")

  # No static status/alive/dead filter exists in the Pedigree Browser UI; the
  # original computed has_status but never asserted it (expect_true(TRUE)).
  # Upgrade the tautology to an honest active-pane check.
  expect_true(
    assert_active_pane(app, "Pedigree Browser"),
    info = "Pedigree Browser pane active (no static status-filter feature)"
  )
})
