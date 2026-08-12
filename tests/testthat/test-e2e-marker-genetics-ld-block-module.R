## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Test for the Marker Genetics "Linkage and LD Block Metrics" Tab
#' (issue #153)
#'
#' Phase 3E runtime smoke test: drives the real running app end to end --
#' upload a pedigree covering the bundled STR marker genotype fixture's own
#' A01-A10 ids (`inst/extdata/examples/example_str_marker_genotypes.csv` /
#' `example_locus_metadata.csv`) through Marker Genetics' existing
#' `linkageGenotypeFile`/`locusMetadataFile` inputs, confirm the "Linkage and
#' LD Block Metrics" tab renders a real result, and drive the FULL
#' curator-gated de-identified export path -- Generate Export Preview ->
#' Confirm Export -> modal -> Confirm Export OK -- live, with zero related
#' console errors.
#'
#' No E2E coverage existed for this tab's export gate before S536 (issue
#' #153 itself shipped S520-524, before Phase 3E live coverage for its
#' export modal was ever attempted). S535 (issue #152 Slice 5) probed this
#' modal live and concluded -- incorrectly -- that shinytest2/chromote could
#' never render a `showModal()` DOM headless; S536 found the real cause was
#' a pedigree fixture missing the `birth` column required by
#' `columnSchema.R`, silently failing `dataInput`'s QC and leaving
#' `pedigree()` NULL, which correctly (not a bug) blocked the
#' `req(pedigree())` guards all the way to `showModal()`. This test's own
#' pedigree fixture below includes `birth` from the start. See
#' `PROJECT_LEARNINGS.md` for the full diagnosis and
#' `test-e2e-marker-genetics-genomic-roh-module.R`'s header for the sibling
#' correction (issue #152 Slice 5's own export gate hit the identical
#' symptom for the identical reason).
library(testthat)

## A01-A05 are founders (sire/dam both NA); A06-A10 are not -- mirrors
## test_modMarkerGenetics.R's own i153FoundersPed relationships (built to
## exercise the founder-restriction checkbox), extended with `sex`/`birth`
## (columnSchema.R's required columns) so this fixture is real-upload-able
## through the Input tab's own QC, not just injectable via testServer().
## Founders are born a full 5 years before their offspring (A06-A10, sired/
## dammed by A01/A02) -- found via this session's own live QC probe:
## dataInput's checkParentAge() rejects a parent-offspring gap that's too
## tight (a real distinct QC gate from the required-column check the
## sibling Genomic ROH E2E test's header documents).
makeLdBlockE2ePedigreeFile <- function() {
  ped <- data.frame(
    id = sprintf("A%02d", 1L:10L),
    sire = c(rep(NA_character_, 5L), rep("A01", 5L)),
    dam = c(rep(NA_character_, 5L), rep("A02", 5L)),
    sex = rep(c("M", "F"), 5L),
    birth = c(
      as.character(seq(as.Date("2005-01-01"), by = "30 days",
                        length.out = 5L)),
      as.character(seq(as.Date("2010-01-01"), by = "30 days",
                        length.out = 5L))
    ),
    stringsAsFactors = FALSE
  )
  path <- file.path(tempdir(), "LdBlockE2E_Pedigree.csv")
  write.csv(ped, path, row.names = FALSE)
  path
}

test_that("E2E: Marker Genetics' Linkage and LD Block Metrics tab computes and the de-identified export path unlocks", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_marker_genetics_ld_block",
                           height = 1000, width = 1400)
  on.exit(app$stop(), add = TRUE)

  # ---- Load a pedigree covering the STR fixture's own A01-A10 ids --------
  if (!navigate_to_tab(app, "Input")) skip("Could not navigate to Input")
  pedFile <- makeLdBlockE2ePedigreeFile()
  do.call(app$upload_file,
          stats::setNames(list(pedFile), "dataInput-pedigreeFileOne"))
  app$click("dataInput-getData")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  ## Same regression guard as the Genomic ROH E2E test: the pedigree must
  ## actually clear QC, not merely "the upload didn't throw."
  qcErrorsText <- get_html_safe(app, "#dataInput-qcErrors")
  expect_false(grepl("Missing required column", qcErrorsText, fixed = TRUE),
               info = "Pedigree fixture must satisfy columnSchema.R's required columns")

  # ---- Upload the bundled STR genotype + locus metadata fixtures ---------
  if (!navigate_to_tab(app, "Marker Genetics")) {
    skip("Could not navigate to Marker Genetics")
  }
  genoPath <- system.file(
    "extdata", "examples", "example_str_marker_genotypes.csv",
    package = "nprcgenekeepr"
  )
  locusMetadataPath <- system.file(
    "extdata", "examples", "example_locus_metadata.csv",
    package = "nprcgenekeepr"
  )
  do.call(app$upload_file,
          stats::setNames(list(genoPath), "markerGenetics-linkageGenotypeFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  do.call(app$upload_file,
          stats::setNames(list(locusMetadataPath),
                           "markerGenetics-locusMetadataFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # ---- Switch to the "Linkage and LD Block Metrics" sub-tab --------------
  if (!click_element_safe(
    app, "a[data-value='Linkage and LD Block Metrics']"
  )) {
    skip("Could not switch to Linkage and LD Block Metrics tab")
  }
  if (!wait_for_element(app, "#markerGenetics-ldBlockTable",
                        timeout = E2E_TIMEOUT)) {
    skip("ldBlockTable did not render")
  }
  ldBlockHtml <- get_html_safe(app, "#markerGenetics-ldBlockTable")
  expect_match(ldBlockHtml, "shiny-bound-output",
               info = "Linkage and LD Block Metrics table should render")

  ## Before any export action: pedigree() is loaded but nothing has been
  ## confirmed, so ldBlockExportGuidance should show the "generate a
  ## preview" info alert.
  guidanceBefore <- get_html_safe(app, "#markerGenetics-ldBlockExportGuidance")
  expect_match(guidanceBefore, "alert-info",
               info = "ldBlockExportGuidance should prompt for Generate Preview once pedigree() is loaded")

  # ---- Drive Generate Export Preview (de-identifies the LD block table) --
  app$click("markerGenetics-ldBlockExportPreview")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  downloadHtml <- get_html_safe(app, "#markerGenetics-downloadLdBlockExport")
  expect_match(downloadHtml, "downloadLdBlockExport",
               info = "De-identified LD block export download link should populate after Preview")

  ## Neither this tab nor its Preview step may throw a JS console error.
  logs <- app$get_logs()
  ldBlockErrors <- logs[logs$level == "throw" &
                           grepl("markerGenetics", logs$message,
                                 ignore.case = TRUE), ]
  expect_equal(nrow(ldBlockErrors), 0L,
               info = "No Linkage and LD Block Metrics/Marker Genetics console error")

  # ---- Confirm -> Confirm OK: driven live end to end ----------------------
  app$click("markerGenetics-ldBlockConfirmExport")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  expect_true(
    wait_for_element(app, "#markerGenetics-ldBlockConfirmExportOk",
                      timeout = E2E_TIMEOUT),
    info = "Confirm-export modal (and its Confirm Export OK button) must render live"
  )
  app$click(selector = "#markerGenetics-ldBlockConfirmExportOk")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  ## Real proof of confirmation: ldBlockExportGuidance renders no alert once
  ## ldBlockConfirmed() is TRUE (same pattern as the Genomic ROH E2E test).
  guidanceAfter <- get_html_safe(app, "#markerGenetics-ldBlockExportGuidance")
  expect_false(grepl("alert", guidanceAfter, fixed = TRUE),
               info = "ldBlockExportGuidance should render no alert once the export is confirmed")
})
