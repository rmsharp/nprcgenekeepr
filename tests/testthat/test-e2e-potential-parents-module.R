#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' E2E Tests for the Potential Parents Module (GitHub issue #48)
#'
#' Opt-in, browser-driven regression tests for the "Potential Parents" tab
#' shipped in Session 80 and owner-verified live in Session 81. They drive the
#' assembled modular app (appUI()/appServer) through shinytest2::AppDriver and
#' exercise the full user chain: upload a fromCenter studbook -> create a
#' pedigree -> compute candidate parents -> populate the sortable table ->
#' download the CSV, plus graceful degradation when the pedigree lacks the
#' colony-origin field.
#'
#' These tests are OPT-IN (NPRC_RUN_E2E=true) and skipped otherwise; see
#' helper-shinytest2.R::create_test_app(). They drive the INSTALLED package, so
#' run devtools::install() first -- the installed copy must carry the module and
#' the inst/extdata/rhesusPedigree_fromCenter.csv fixture.
library(testthat)

# The fromCenter demo fixture (375 animals; added in Session 81) yields exactly
# this many in-colony animals with at least one unknown parent at the QC-default
# minParentAge = 2 and maxGestationalPeriod = 210. Locked as the regression
# value (owner-verified live in Session 81: "Found candidate parents for 50
# animal(s)").
PP_EXPECTED_CANDIDATES <- 50L

test_that("E2E: Potential Parents tab is accessible", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pp_access")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Potential Parents", "Potential Parents")
  if (!success) skip("Could not navigate to Potential Parents tab")

  # Static heading / description text rendered by modPotentialParentsUI().
  expect_true(
    assert_active_pane(app, "Potential Parents",
                       "potential|candidate|gestation"),
    info = "Should be on the Potential Parents tab"
  )
})

test_that("E2E: Potential Parents has gestation/find/download controls", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pp_controls")
  on.exit(app$stop(), add = TRUE)

  success <- navigate_to_tab(app, "Potential Parents", "Potential Parents")
  if (!success) skip("Could not navigate to Potential Parents tab")

  # Matches the always-visible numericInput label "Maximum Gestational
  # Period (days)", the "Find Potential Parents" actionButton, and the
  # "Download CSV" downloadButton.
  expect_true(
    assert_active_pane(app, "Potential Parents",
                       "gestational|find potential parents|download"),
    info = "Should expose the gestation input, Find button, and CSV download"
  )
})

test_that("E2E: Potential Parents populates table and downloads CSV", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pp_populated")
  on.exit(app$stop(), add = TRUE)

  fixture <- get_test_data_path("rhesusPedigree_fromCenter.csv")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC of the fromCenter fixture did not complete")

  # Visit Pedigree Browser to materialize shared$currentPedigree (mirrors the
  # Session 81 manual flow), then switch to the Potential Parents tab.
  if (!navigate_to_tab(app, "Pedigree Browser", "Pedigree")) {
    skip("Could not navigate to Pedigree Browser tab")
  }
  if (!navigate_to_tab(app, "Potential Parents", "Potential Parents")) {
    skip("Could not navigate to Potential Parents tab")
  }

  # Pin the gestational period to the verified value, then compute. The UI
  # already prefills 210; setting it makes the regression value explicit.
  app$set_inputs(`potentialParents-maxGestationalPeriod` = 210, wait_ = FALSE)
  clicked <- click_element_safe(app, "#potentialParents-findParents")
  if (!clicked) skip("Could not click the Find Potential Parents button")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # Status message reports the candidate count (only rendered when
  # getPotentialParents() actually returns candidates -> assertion has teeth).
  status_html <- get_html_safe(app, "#potentialParents-statusMessage")
  expect_match(
    status_html,
    sprintf("Found candidate parents for %d animal", PP_EXPECTED_CANDIDATES),
    info = "Status message should report the candidate-animal count"
  )

  # DataTable info text ("Showing 1 to 25 of 50 entries") confirms the rendered,
  # data-bearing table -- not just the empty widget shell.
  table_html <- get_html_safe(app, "#potentialParents-resultsTable")
  expect_match(
    table_html,
    sprintf("of %d entries", PP_EXPECTED_CANDIDATES),
    info = "Results DataTable should display all candidate animals"
  )

  # Exercise the CSV download end to end: the handler writes the flattened
  # candidate table via write.csv().
  csv_path <- app$get_download("potentialParents-downloadParents")
  downloaded <- read.csv(csv_path, stringsAsFactors = FALSE,
                         colClasses = "character")
  expect_equal(
    nrow(downloaded), PP_EXPECTED_CANDIDATES,
    info = "Downloaded CSV should contain one row per candidate animal"
  )
  expect_identical(
    names(downloaded),
    c("id", "nSires", "nDams", "sires", "dams"),
    info = "Downloaded CSV should carry the flattened candidate-parent columns"
  )
})

test_that("E2E: Potential Parents degrades gracefully without fromCenter", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_pp_no_fromcenter")
  on.exit(app$stop(), add = TRUE)

  # ExamplePedigree.csv is QC-clean but carries NO fromCenter colony-origin
  # field, so a pedigree is created but getPotentialParents() returns NULL.
  fixture <- get_test_data_path("ExamplePedigree.csv")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC of the ExamplePedigree fixture did not complete")

  if (!navigate_to_tab(app, "Pedigree Browser", "Pedigree")) {
    skip("Could not navigate to Pedigree Browser tab")
  }
  if (!navigate_to_tab(app, "Potential Parents", "Potential Parents")) {
    skip("Could not navigate to Potential Parents tab")
  }

  clicked <- click_element_safe(app, "#potentialParents-findParents")
  if (!clicked) skip("Could not click the Find Potential Parents button")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # The fromCenter-specific warning (NOT the "No pedigree is loaded" branch),
  # which proves the pedigree materialized but lacks the colony-origin field.
  status_html <- get_html_safe(app, "#potentialParents-statusMessage")
  expect_match(
    status_html, "colony-origin",
    info = "Should warn that the dataset lacks the fromCenter colony-origin field"
  )
})
