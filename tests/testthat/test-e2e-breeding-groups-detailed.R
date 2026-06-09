#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Detailed E2E Tests for Breeding Groups Module
library(testthat)

test_that("E2E: Breeding Groups has group size control", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_group_size")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # DRAGON: no literal "size" control in modBreedingGroups; the pattern matches
  # via "number"/"animals" ("Number of groups:", "Number of top animals:",
  # "Seed groups with specific animals"). The test name overclaims "size" -- keep
  # the pattern verbatim and do not rename (flag, don't retarget).
  expect_true(
    assert_active_pane(app, "Breeding Groups", "size|number|count|animals"),
    info = "Should have group size control"
  )
})

test_that("E2E: Breeding Groups has harem option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_harem")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # REVIVE: was expect_true(TRUE) with a dead grepl. Narrow the revived pattern
  # to "harem" -- the always-visible "Harem (1M:NF)" sex-ratio choice; the dead
  # "single male"/"breeding system" alternatives are never rendered (pruned).
  expect_true(
    assert_active_pane(app, "Breeding Groups", "harem"),
    info = "Should have harem option"
  )
})

test_that("E2E: Breeding Groups has minimum age setting", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_min_age")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  expect_true(
    assert_active_pane(app, "Breeding Groups", "age|minimum|year|breeding"),
    info = "Should have minimum age setting"
  )
})

test_that("E2E: Breeding Groups has results display area", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_results")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # REVIVE: was expect_true(TRUE) with a dead grepl. "group" matches the
  # always-visible "Number of groups:"/"Seed groups ..."/nested "Groups" nav; the
  # other alternatives (result/table/output/formed) are the data-dependent
  # formed-group display rendered post-formation -> asserted in 8e-6.
  expect_true(
    assert_active_pane(app, "Breeding Groups", "result|group|table|output|formed"),
    info = "Should have results display area"
  )
})

test_that("E2E: Breeding Groups has export functionality", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_export")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # NULL (pane-active only): the Export/Download buttons live in the INACTIVE
  # "Group Detail" nested tab (display:none -> not in the active pane innerText)
  # and the guidance HTML has no export text. Assert the pane is active/visible;
  # the export-button assertion is deferred to 8e-6 (nested-tab navigation).
  expect_true(
    assert_active_pane(app, "Breeding Groups"),
    info = "Breeding Groups pane should be active"
  )
})

test_that("E2E: Breeding Groups shows algorithm description", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_algorithm")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  # ANCHOR: was a content-length tautology (nchar(html) > 200). Anchor to
  # "algorithm" -- the always-visible guidance (group_formation.html: "The
  # algorithm ignores between-animal kinship..."), faithful to the test's
  # "algorithm description" intent.
  expect_true(
    assert_active_pane(app, "Breeding Groups", "algorithm"),
    info = "Breeding Groups should show algorithm description"
  )
})

test_that("E2E: Breeding Groups has kinship constraint option", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_kinship_constraint")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  expect_true(
    assert_active_pane(app, "Breeding Groups",
                       "kinship|threshold|maximum|constraint|related"),
    info = "Should have kinship constraint option"
  )
})
