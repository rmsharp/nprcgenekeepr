#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Pedigree Browser Module
library(testthat)

test_that("E2E: Pedigree Browser tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "Pedigree|Browser|Animal"),
    info = "Should be on Pedigree Browser tab"
  )
})

test_that("E2E: Pedigree Browser has focal animal controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_focal_controls")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "focal|animal|filter|update"),
    info = "Should have focal animal controls"
  )
})

test_that("E2E: Pedigree Browser has export functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_export")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "export|download|csv"),
    info = "Should have export functionality"
  )
})

test_that("E2E: Pedigree Browser has data table", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_datatable")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  # 8e-6a: assert the data-bearing rendered pedigree DataTable. The DataTable
  # DOM (row-count info + parent columns) renders only once the Pedigree Browser
  # tab is active AND a studbook has been loaded (req(pedigreeData())).
  html <- get_html_safe(app, "#pedigree-pedigreeTable")
  expect_match(
    html, "of 375 entries",
    info = "DataTable displays all 375 fixture pedigree rows"
  )
  expect_match(
    html, "sire",
    info = "Pedigree table includes the sire parent column"
  )
})

test_that("E2E: Pedigree Browser trim pedigree option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pedigree_trim")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  expect_true(
    assert_active_pane(app, "Pedigree Browser", "trim|subset|filter"),
    info = "Should have trim pedigree option"
  )
})
