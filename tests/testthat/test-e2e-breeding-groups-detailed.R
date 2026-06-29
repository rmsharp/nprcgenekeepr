## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
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

  fixture <- system.file("extdata", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  if (!upload_and_wait(app, fixture)) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  app$set_inputs(`breedingGroups-animalSource` = "all",
                 `breedingGroups-nIterations` = 5, wait_ = FALSE)
  if (!click_element_safe(app, "#breedingGroups-formGroups")) {
    skip("Form Groups click failed")
  }
  if (!wait_for_module_ready(app, "breedingGroups", timeout = 180000)) {
    skip("Group formation did not complete")
  }
  if (!click_element_safe(app, "a[data-value='Group Detail']")) {
    skip("Group Detail tab activation failed")
  }

  # 8e-6c GREEN: real breeding flow (upload -> QC -> form groups -> activate the
  # Group Detail nested tab) drives the data-bearing assertions. The export
  # button label appears in the visible pane only after Group Detail activation;
  # the member DTOutput (suspendWhenHidden) renders real rows only after group
  # formation. Both tokens are static labels / rendered column headers ->
  # seed-independent (Option C structural).
  expect_true(
    assert_active_pane(app, "Breeding Groups", "Export Current Group"),
    info = "Group Detail export button should be visible after forming groups"
  )
  expect_true(
    grepl("Ego ID", get_html_safe(app, "#breedingGroups-groupMemberTable")),
    info = "Group member table should render real data (data-bearing)"
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
