#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for Breeding Group Formation - Tutorial Coverage
#' Based on ColonyManagerTutorial.Rmd workflow
library(testthat)

test_that("E2E: Breeding Groups has workflow selection", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_workflow")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # REVIVE: was expect_true(TRUE). "group.*formation" matches the always-visible
  # h3 "Breeding Group Formation" / guidance "group formation simulation"; the
  # dead "workflow"/"Choose.*group" framing alternatives are never rendered
  # (pruned). "source.*animal" retained (real Source-control concept).
  expect_true(
    assert_active_pane(app, "Breeding Groups", "group.*formation|source.*animal"),
    info = "Should have workflow selection"
  )
})

test_that("E2E: Breeding Groups has sex ratio options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_sex_ratio_opts")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # Tutorial mentions three sex ratio options including user-specified
  expect_true(
    assert_active_pane(app, "Breeding Groups",
                       "sex.*ratio|ratio.*breeder|F/M|female.*male|sexRatio"),
    info = "Should have sex ratio options"
  )
})

test_that("E2E: Breeding Groups has Make Groups button", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_make_groups")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  expect_true(
    assert_active_pane(app, "Breeding Groups",
                       "Make.*Group|Form.*Group|Create.*Group|makeGroups|formGroups"),
    info = "Should have Make Groups button"
  )
})

test_that("E2E: Breeding Groups has seed groups option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_seed_groups")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # REVIVE: was expect_true(TRUE). The always-visible checkbox label "Seed
  # groups with specific animals" matches "Seed.*Group"/"seed.*animal"/
  # "specific.*animal"; the dead "pre.*seed" (never rendered) and "seedGroups"
  # (inputId, not in innerText) alternatives are pruned.
  expect_true(
    assert_active_pane(app, "Breeding Groups",
                       "Seed.*Group|seed.*animal|specific.*animal"),
    info = "Should have seed groups option"
  )
})

test_that("E2E: Breeding Groups has infants with dam option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_infants_dam")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # NULL (pane-active only): the modular Breeding Groups UI has NO
  # infants-with-dam control (tutorial-only concept; no faithful token is
  # default-visible). Assert the pane is active/visible; if such a control is
  # ever added, give it a real pattern then.
  expect_true(
    assert_active_pane(app, "Breeding Groups"),
    info = "Breeding Groups pane should be active"
  )
})

test_that("E2E: Breeding Groups has include kinship option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_include_kinship")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # REVIVE: was expect_true(TRUE). The always-visible checkbox label "Include
  # kinship in display of groups" matches "Include.*kinship"/"kinship.*display";
  # the dead "showKinship" (inputId) and "display.*kinship" (label order is
  # kinship-before-display, non-matching) alternatives are pruned.
  expect_true(
    assert_active_pane(app, "Breeding Groups", "Include.*kinship|kinship.*display"),
    info = "Should have include kinship option"
  )
})

test_that("E2E: Breeding Groups has group export options", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_export_groups")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # NULL (pane-active only): the Export/Download buttons live in the INACTIVE
  # "Group Detail" nested tab (display:none -> not in the active pane innerText);
  # guidance HTML has no export text. Deferred to 8e-6 (nested-tab navigation).
  expect_true(
    assert_active_pane(app, "Breeding Groups"),
    info = "Breeding Groups pane should be active"
  )
})

test_that("E2E: Breeding Groups has high-value animals source", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_high_value_source")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # REVIVE: was expect_true(TRUE). Narrow to "top.*ranked" -- the always-visible
  # "Top ranked" animal-source radio choice. "high.*value"/"value.*animal" are
  # never rendered and "genetic.*analysis" is foreign to this module (it is the
  # Genetic Value pane) -- all pruned.
  expect_true(
    assert_active_pane(app, "Breeding Groups", "top.*ranked"),
    info = "Should have high-value animals source"
  )
})

test_that("E2E: Breeding Groups has kinship matrix export per group", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_kinship_matrix_export")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # NULL (pane-active only): the "Export Current Group Kinship Matrix" button is
  # in the INACTIVE "Group Detail" nested tab (display:none); the guidance kinship
  # table has no "matrix"/"export" tokens. Deferred to 8e-6 (nested-tab + data).
  expect_true(
    assert_active_pane(app, "Breeding Groups"),
    info = "Breeding Groups pane should be active"
  )
})
