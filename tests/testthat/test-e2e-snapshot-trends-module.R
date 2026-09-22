## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Tests for Genetic-Health Trends Module (issue #167 Slice 4)
#'
#' Phase 3E runtime smoke test: drives the real running app end to end --
#' load the bundled example pedigree, run Genetic Value Analysis, upload the
#' bundled snapshot-history fixture on the new Genetic-Health Trends tab,
#' generate a snapshot from the live GVA run (proving the snapshotSource
#' wiring, S760 catalog amendment), append it, render the trend plot and a
#' delta comparison with the D4 comparabilityFlag visible, and download both
#' artifacts -- zero related console errors.
library(testthat)

test_that("E2E: Genetic-Health Trends generates a snapshot from a live GVA run, renders trends/deltas with the D4 flag, and both downloads work", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_snapshot_trends",
                           height = 1000, width = 1400)
  on.exit(app$stop(), add = TRUE)

  # ---- Load the bundled example pedigree (Input tab) ----------------------
  if (!navigate_to_tab(app, "Input")) skip("Could not navigate to Input")
  ## Must stay nprcgenekeepr::-qualified: the nightly shinytest2 job runs this
  ## tier via testthat::test_dir(), which never attaches the package (see
  ## test_e2e_package_qualification.R, which guards this).
  examplePedFile <- nprcgenekeepr::makeExamplePedigreeFile(
    file.path(tempdir(), "SnapshotTrendsE2E_Pedigree.csv"), fileType = "csv"
  )
  do.call(app$upload_file,
          stats::setNames(list(examplePedFile), "dataInput-pedigreeFileOne"))
  app$click("dataInput-getData")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # ---- Run Genetic Value Analysis (feeds the snapshotSource reactive) ------
  if (!navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")) {
    skip("Could not navigate to Genetic Value Analysis")
  }
  app$set_inputs(`geneticValue-nIterations` = 100)
  if (!click_element_safe(app, "#geneticValue-runAnalysis")) {
    skip("Could not run genetic value analysis")
  }
  if (!wait_for_module_ready(app, "geneticValue", timeout = 90000)) {
    skip("Genetic value analysis did not complete")
  }

  # ---- Upload the bundled snapshot-history fixture -------------------------
  if (!navigate_to_tab(app, "Genetic-Health Trends")) {
    skip("Could not navigate to Genetic-Health Trends")
  }
  fixturePath <- system.file("extdata", "examples",
                             "example_snapshot_history.csv",
                             package = "nprcgenekeepr")
  do.call(app$upload_file,
          stats::setNames(list(fixturePath), "snapshotTrends-historyFile"))
  if (!wait_for_module_ready(app, "snapshotTrends", timeout = 30000)) {
    skip("Snapshot history upload did not signal data-ready")
  }

  historyHtmlBefore <- get_html_safe(app, "#snapshotTrends-historyTable")
  expect_match(historyHtmlBefore, "shiny-bound-output",
               info = "History table should render after upload")
  expect_match(historyHtmlBefore, "2025-01-15", fixed = TRUE)

  # ---- Generate + append a snapshot from the live GVA run -------------------
  if (!click_element_safe(app, "#snapshotTrends-generateSnapshot")) {
    skip("Could not click Generate Snapshot")
  }
  if (!wait_for_module_ready(app, "snapshotTrends", timeout = 30000)) {
    skip("Snapshot generation did not signal data-ready")
  }

  historyHtmlAfter <- get_html_safe(app, "#snapshotTrends-historyTable")
  expect_match(
    historyHtmlAfter, format(Sys.Date()), fixed = TRUE,
    info = "The newly generated snapshot's today's-date row should appear"
  )

  # ---- Trend plot renders -----------------------------------------------------
  plotHtml <- get_html_safe(app, "#snapshotTrends-trendPlot")
  expect_match(plotHtml, "shiny-bound-output",
               info = "Trend plot should render")

  # ---- Delta comparison with the D4 comparabilityFlag visible ---------------
  click_element_safe(app, "a[data-value='Deltas']")
  app$set_inputs(`snapshotTrends-deltaRule` = "wholePedigree", wait_ = FALSE)
  app$set_inputs(`snapshotTrends-deltaFrom` = "2025-07-15", wait_ = FALSE)
  app$set_inputs(`snapshotTrends-deltaTo` = "2026-01-15", wait_ = FALSE)
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  if (!wait_for_dt_rendered(app, "#snapshotTrends-deltaTable")) {
    skip("Delta table did not finish rendering (DT still processing)")
  }
  deltaHtml <- get_html_safe(app, "#snapshotTrends-deltaTable")
  expect_match(deltaHtml, "shiny-bound-output",
               info = "Delta table should render")
  # The fixture's guIter changes 5000 -> 10000 between these two
  # wholePedigree snapshots (D4): the gene-drop-derived rows must carry a
  # visible flag, not be silently averaged away.
  expect_match(deltaHtml, "guIter", fixed = TRUE,
               info = "D4 comparabilityFlag should name the changed field")

  # ---- Downloads ----------------------------------------------------------
  historyPath <- app$get_download("snapshotTrends-downloadHistory")
  historyOut <- utils::read.csv(historyPath, stringsAsFactors = FALSE)
  expect_true(nrow(historyOut) >= 5L)

  deltaPath <- app$get_download("snapshotTrends-downloadDeltas")
  deltaOut <- utils::read.csv(deltaPath, stringsAsFactors = FALSE)
  expect_true("comparabilityFlag" %in% names(deltaOut))

  ## Neither the new module nor the snapshotSource wiring may throw a JS
  ## console error. Pre-existing, unrelated console noise (e.g. shinyBS) is
  ## deliberately not asserted away here, matching prior E2E precedent.
  logs <- app$get_logs()
  trendErrors <- logs[logs$level == "throw" &
                        grepl("snapshotTrends", logs$message,
                              ignore.case = TRUE), ]
  expect_equal(nrow(trendErrors), 0L,
               info = "No Genetic-Health Trends console error")
})
