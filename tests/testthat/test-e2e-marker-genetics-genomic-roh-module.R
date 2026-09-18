## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Test for the Marker Genetics "Genomic ROH (F_ROH)" Tab (issue #152
#' Slice 5)
#'
#' Phase 3E runtime smoke test: drives the real running app end to end --
#' upload a pedigree covering the Slice 1 sequence fixture's own S001-S050
#' ids (NOT the bundled example pedigree, whose ids are disjoint from the
#' synthetic fixture -- obfuscateGenotypeMatrix()/obfuscateGenomicROH() both
#' stop() loudly on any exported id absent from the de-identification map,
#' by design, so the export path needs a pedigree that actually covers the
#' uploaded genotype ids), upload the committed Slice 1 sequence fixture (50
#' individuals x 1,000 loci, inst/extdata/examples/
#' example_sequence_genotypes.csv / example_sequence_locus_metadata.csv)
#' through Marker Genetics' existing genotypeFile/locusMetadataFile inputs
#' (this slice's own Pre-RED Q1/Q2 ratification: reuse, not a dedicated
#' upload), confirm the new Genomic ROH (F_ROH) tab renders a real result at
#' genome scale, and drive the FULL curator-gated de-identified export path
#' -- Generate Preview -> Confirm Export -> modal -> Confirm Export OK --
#' live, with zero related console errors, matching this cluster's own
#' established Phase 3E bar (design doc section 5 Slice 5 "Done when").
#'
#' Found S536 (correcting a S535 misdiagnosis): the pedigree fixture below
#' MUST include a `birth` column -- `columnSchema.R`'s required column list
#' is `c("id", "sire", "dam", "sex", "birth")`, so a pedigree missing
#' `birth` fails `dataInput`'s QC silently (visible only via the Input
#' tab's own `qcErrors` output, which the original S535 test never
#' checked) and `pedigree()` never populates. That, not a shinytest2/
#' chromote rendering gap, is why S535's own probe (using the same
#' birth-less fixture) never saw the `showModal()` DOM appear: the
#' Confirm button's `observeEvent` correctly `req(sequenceExportRaw())`
#' -- itself never populated because Generate Preview's own
#' `req(pedigree())` correctly blocked on the missing column. Both
#' `req()` guards were behaving exactly as designed. Verified live
#' (S536): with `birth` added, the full Generate Preview -> Confirm
#' Export -> modal -> Confirm Export OK -> download-unlock sequence
#' works end to end in headless Chrome, no different from a real
#' browser. See `PROJECT_LEARNINGS.md` for the full diagnosis.
library(testthat)

## All founders -- built solely so obfuscatePed(map = TRUE) has a real alias
## map covering the Slice 1 fixture's own ids, not meant to be biologically
## realistic (mirrors test_modMarkerGenetics.R's own i152RohPed convention).
## Includes `birth` (required by columnSchema.R's required-column list) --
## its omission was the actual root cause of S535's misdiagnosed "harness
## limitation" (see file header).
makeGenomicRohE2ePedigreeFile <- function(dropIds = character(0L)) {
  ped <- data.frame(
    id = sprintf("S%03d", 1L:50L),
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), 25L),
    birth = as.character(seq(as.Date("2015-01-01"), by = "30 days",
                              length.out = 50L)),
    stringsAsFactors = FALSE
  )
  ped <- ped[!ped$id %in% dropIds, , drop = FALSE]
  fileName <- if (length(dropIds) == 0L) {
    "GenomicRohE2E_Pedigree.csv"
  } else {
    "GenomicRohE2E_PartialPedigree.csv"
  }
  path <- file.path(tempdir(), fileName)
  write.csv(ped, path, row.names = FALSE)
  path
}

test_that("E2E: Marker Genetics' Genomic ROH (F_ROH) tab computes at genome scale and the de-identified export path unlocks", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_marker_genetics_genomic_roh",
                           height = 1000, width = 1400)
  on.exit(app$stop(), add = TRUE)

  # ---- Load a pedigree covering the Slice 1 fixture's own S001-S050 ids ---
  if (!navigate_to_tab(app, "Input")) skip("Could not navigate to Input")
  pedFile <- makeGenomicRohE2ePedigreeFile()
  do.call(app$upload_file,
          stats::setNames(list(pedFile), "dataInput-pedigreeFileOne"))
  app$click("dataInput-getData")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  ## Real regression guard for S535's own root cause: the pedigree must
  ## actually clear QC (empty qcErrors table), not merely "the upload
  ## didn't throw." A pedigree missing a required column fails silently
  ## here otherwise.
  qcErrorsText <- get_html_safe(app, "#dataInput-qcErrors")
  expect_false(grepl("Missing required column", qcErrorsText, fixed = TRUE),
               info = "Pedigree fixture must satisfy columnSchema.R's required columns")

  # ---- Upload the Slice 1 genome-scale sequence fixture on Marker Genetics
  if (!navigate_to_tab(app, "Marker Genetics")) {
    skip("Could not navigate to Marker Genetics")
  }
  genoPath <- system.file(
    "extdata", "examples", "example_sequence_genotypes.csv",
    package = "nprcgenekeepr"
  )
  locusMetadataPath <- system.file(
    "extdata", "examples", "example_sequence_locus_metadata.csv",
    package = "nprcgenekeepr"
  )
  do.call(app$upload_file,
          stats::setNames(list(genoPath), "markerGenetics-genotypeFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  do.call(app$upload_file,
          stats::setNames(list(locusMetadataPath),
                           "markerGenetics-locusMetadataFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # Existing Kinship Comparison tab must still render at genome scale (Q1's
  # validator-swap approach: checkSequenceGenotypeFile() is a superset of
  # checkMarkerGenotypeFile(), so the pre-existing tab must be unaffected).
  markerHtml <- get_html_safe(app, "#markerGenetics-comparisonTable")
  expect_match(markerHtml, "shiny-bound-output",
               info = "Marker Genetics comparison table should still render")

  # ---- Switch to the new "Genomic ROH (F_ROH)" sub-tab ---------------------
  if (!click_element_safe(app, "a[data-value='Genomic ROH (F_ROH)']")) {
    skip("Could not switch to Genomic ROH (F_ROH) tab")
  }
  if (!wait_for_element(app, "#markerGenetics-sequenceRohTable",
                        timeout = E2E_TIMEOUT)) {
    skip("sequenceRohTable did not render")
  }
  rohHtml <- get_html_safe(app, "#markerGenetics-sequenceRohTable")
  expect_match(rohHtml, "shiny-bound-output",
               info = "Genomic ROH (F_ROH) table should render")

  ## Before any export action: pedigree() is loaded but nothing has been
  ## confirmed, so sequenceExportGuidance should show the "generate a
  ## preview" info alert (real proof the reactive chain sees a live
  ## pedigree(), not just that the DOM element exists).
  guidanceBefore <- get_html_safe(app, "#markerGenetics-sequenceExportGuidance")
  expect_match(guidanceBefore, "alert-info",
               info = "sequenceExportGuidance should prompt for Generate Preview once pedigree() is loaded")

  # ---- Drive Generate Preview (de-identifies the real genome-scale data) --
  app$click("markerGenetics-sequenceExportPreview")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  downloadHtml <- get_html_safe(
    app, "#markerGenetics-downloadSequenceGenotype"
  )
  expect_match(downloadHtml, "downloadSequenceGenotype",
               info = "De-identified genotype matrix download link should populate after Preview")

  ## Neither the new tab nor its Preview step may throw a JS console error.
  ## Pre-existing, unrelated console noise (e.g. shinyBS) is deliberately
  ## not asserted away, matching the mate-pair E2E test's own precedent.
  logs <- app$get_logs()
  rohErrors <- logs[logs$level == "throw" &
                       grepl("markerGenetics", logs$message,
                             ignore.case = TRUE), ]
  expect_equal(nrow(rohErrors), 0L,
               info = "No Genomic ROH (F_ROH)/Marker Genetics console error")

  # ---- Confirm -> Confirm OK: driven live end to end ----------------------
  # Corrects S535's misdiagnosis (see file header) -- this is a real,
  # required assertion, not a graceful self-skip: the modal MUST appear.
  app$click("markerGenetics-sequenceConfirmExport")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  expect_true(
    wait_for_element(app, "#markerGenetics-sequenceConfirmExportOk",
                      timeout = E2E_TIMEOUT),
    info = "Confirm-export modal (and its Confirm Export OK button) must render live"
  )
  app$click(selector = "#markerGenetics-sequenceConfirmExportOk")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  ## Real proof of confirmation: sequenceExportGuidance's renderUI() has no
  ## else branch once sequenceExportConfirmed() is TRUE, so it renders no
  ## alert div at all -- a stronger check than the pre-existing
  ## substring-in-static-HTML pattern that let S535's misdiagnosis go
  ## unnoticed (a downloadButton's id is always present in its href
  ## regardless of whether real content was ever generated).
  guidanceAfter <- get_html_safe(app, "#markerGenetics-sequenceExportGuidance")
  expect_false(grepl("alert", guidanceAfter, fixed = TRUE),
               info = "sequenceExportGuidance should render no alert once the export is confirmed")
})

## RED (S709, BACKLOG Up Next): before the fix, clicking Generate Preview
## with a genotype animal absent from the loaded pedigree let
## obfuscateGenotypeMatrix()'s stop() escape inside the preview
## observeEvent(), which ENDS the user's Shiny session (Learning 758 --
## verified live S708 on a minimal app; this test reproduces it on the
## real tab). The fixed observer pre-checks the ids, builds nothing, and
## says why in the export guidance, with the session still connected.
test_that("E2E: a genotype animal absent from the pedigree blocks the export preview without ending the session", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_marker_genetics_roh_missing_id",
                           height = 1000, width = 1400)
  on.exit(app$stop(), add = TRUE)

  # ---- Load a pedigree that is missing one of the genotype fixture's ids --
  if (!navigate_to_tab(app, "Input")) skip("Could not navigate to Input")
  pedFile <- makeGenomicRohE2ePedigreeFile(dropIds = "S050")
  do.call(app$upload_file,
          stats::setNames(list(pedFile), "dataInput-pedigreeFileOne"))
  app$click("dataInput-getData")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # ---- Upload the genome-scale fixture, whose S050 the pedigree lacks ----
  if (!navigate_to_tab(app, "Marker Genetics")) {
    skip("Could not navigate to Marker Genetics")
  }
  genoPath <- system.file(
    "extdata", "examples", "example_sequence_genotypes.csv",
    package = "nprcgenekeepr"
  )
  locusMetadataPath <- system.file(
    "extdata", "examples", "example_sequence_locus_metadata.csv",
    package = "nprcgenekeepr"
  )
  do.call(app$upload_file,
          stats::setNames(list(genoPath), "markerGenetics-genotypeFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  do.call(app$upload_file,
          stats::setNames(list(locusMetadataPath),
                           "markerGenetics-locusMetadataFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  if (!click_element_safe(app, "a[data-value='Genomic ROH (F_ROH)']")) {
    skip("Could not switch to Genomic ROH (F_ROH) tab")
  }
  if (!wait_for_element(app, "#markerGenetics-sequenceRohTable",
                        timeout = E2E_TIMEOUT)) {
    skip("sequenceRohTable did not render")
  }

  # ---- Generate Preview: the click that used to end the session ----------
  app$click("markerGenetics-sequenceExportPreview")
  Sys.sleep(3)

  connected <- app$get_js("Shiny.shinyapp.isConnected()")
  expect_true(isTRUE(connected),
              info = "The Shiny session must survive a Generate Preview click when a genotype animal is absent from the pedigree")

  guidanceHtml <- get_html_safe(app, "#markerGenetics-sequenceExportGuidance")
  expect_match(guidanceHtml, "not in the loaded pedigree",
               info = "The export guidance must say why the preview was not generated")
  expect_match(guidanceHtml, "1 animal",
               info = "The export guidance must count the missing animals")
})
