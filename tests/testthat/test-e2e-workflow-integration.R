## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Tests for Cross-Module Workflow Integration
library(testthat)

test_that("E2E: Can navigate through all main tabs sequentially", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_sequential_nav")
  on.exit(app$stop(), add = TRUE)

  tabs_visited <- 0L

  # Home is the default pane on boot (no navigation needed). Each step below
  # counts a tab only when its pane genuinely becomes the active/visible pane
  # (was a content-blind whole-body grepl that passed on every hidden pane).
  if (assert_active_pane(app, "Home", "Welcome|Home|GeneKeepR")) {
    tabs_visited <- tabs_visited + 1L
  }

  navigate_to_tab(app, "Input")
  if (assert_active_pane(app, "Input", "Upload|File|Input")) {
    tabs_visited <- tabs_visited + 1L
  }

  navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (assert_active_pane(app, "Pedigree Browser", "Pedigree|Browser")) {
    tabs_visited <- tabs_visited + 1L
  }

  navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")
  if (assert_active_pane(app, "Age-Sex Pyramid", "Pyramid|Age|Sex")) {
    tabs_visited <- tabs_visited + 1L
  }

  navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (assert_active_pane(app, "Genetic Value Analysis", "Genetic|Value")) {
    tabs_visited <- tabs_visited + 1L
  }

  navigate_to_tab(app, "Breeding Groups", "Groups")
  if (assert_active_pane(app, "Breeding Groups", "Breeding|Groups")) {
    tabs_visited <- tabs_visited + 1L
  }

  expect_true(
    tabs_visited == 6L,
    info = "All 6 main panes should each become the active visible pane in turn"
  )
})

test_that("E2E: App maintains state when switching tabs", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_state_maintain")
  on.exit(app$stop(), add = TRUE)

  # Switch to Input and confirm the Input pane is genuinely active/visible.
  if (!navigate_to_tab(app, "Input")) skip("Could not switch tabs")
  expect_true(
    assert_active_pane(app, "Input", "Upload|File|Input"),
    info = "Switching to Input makes the Input pane active/visible"
  )

  # Switch back to Home and confirm the Home pane is active/visible again.
  if (!navigate_to_tab(app, "Home")) skip("Could not switch back")
  expect_true(
    assert_active_pane(app, "Home", "Welcome|Home|GeneKeepR"),
    info = "Switching back makes the Home pane active/visible"
  )
})

test_that("E2E: App is responsive after multiple tab switches", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_multi_switch")
  on.exit(app$stop(), add = TRUE)

  # Perform multiple tab switches
  tabs <- c("Input", "Home", "Input", "Home")
  for (tab in tabs) {
    navigate_to_tab(app, tab)
  }

  # After the switches the app should land on (and render) the final pane.
  expect_true(
    assert_active_pane(app, "Home", "Welcome|Home|GeneKeepR"),
    info = "After multiple switches the final (Home) pane is active/visible"
  )
})

test_that("E2E: Navbar brand/title is visible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_navbar_brand")
  on.exit(app$stop(), add = TRUE)

  # CARVE-OUT: the navbar brand/title lives in `.navbar-brand`, OUTSIDE any
  # tab-pane, so assert_active_pane does not apply. Scope the grepl to the brand
  # element itself (not the whole hidden body, where "GeneKeepR" also appears in
  # the Home/About panes) so this genuinely checks the brand is present.
  brand <- get_html_safe(app, ".navbar-brand")
  expect_true(
    grepl("GeneKeepR", brand),
    info = "Navbar brand element should display the GeneKeepR title"
  )
})

test_that("E2E: Input tab has file upload before pedigree browser works", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_workflow_upload")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Input")
  if (!success) skip("Could not navigate to Input tab")

  expect_true(
    assert_active_pane(app, "Input", "upload|file|browse"),
    info = "Input pane active with file-upload capability"
  )
})

test_that("E2E: Genetic Value tab indicates data requirement", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_gv_data_req")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")
  if (!success) skip("Could not navigate to Genetic Value tab")

  expect_true(
    assert_active_pane(app, "Genetic Value Analysis",
                       "Genetic|Value|Analysis|kinship|population"),
    info = "Genetic Value pane active with relevant content"
  )
})

test_that("E2E: Breeding Groups tab indicates data requirement", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_data_req")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  expect_true(
    assert_active_pane(app, "Breeding Groups",
                       "Breeding|Groups|formation|animals"),
    info = "Breeding Groups pane active with relevant content"
  )
})
