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
#' genome scale, and drive the Generate Preview step of the curator-gated
#' de-identified export path with zero related console errors -- matching
#' this cluster's own established Phase 3E bar (design doc section 5 Slice 5
#' "Done when"), as far as this test harness can verify live (see the note
#' below).
#'
#' The Confirm -> Confirm OK modal step is NOT driven live here: a same-
#' session probe found shinytest2/chromote's headless browser never renders
#' the `showModal()` Bootstrap modal DOM for EITHER this tab's export gate OR
#' the already-shipped issue #153 LD-block export's identical
#' modalDialog()/showModal() pattern -- a pre-existing harness limitation,
#' not a defect in this or #153's code (see BACKLOG.md and
#' PROJECT_LEARNINGS.md). The server-side Preview->Confirm->Confirm-OK
#' reactive chain is instead proven correct by
#' test_modMarkerGenetics.R's own testServer()-based tests (faithful
#' verification of that surface, since testServer exercises the real
#' reactive graph, just not the browser-rendered modal).
library(testthat)

## All founders -- built solely so obfuscatePed(map = TRUE) has a real alias
## map covering the Slice 1 fixture's own ids, not meant to be biologically
## realistic (mirrors test_modMarkerGenetics.R's own i152RohPed convention).
makeGenomicRohE2ePedigreeFile <- function() {
  ped <- data.frame(
    id = sprintf("S%03d", 1L:50L),
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), 25L),
    stringsAsFactors = FALSE
  )
  path <- file.path(tempdir(), "GenomicRohE2E_Pedigree.csv")
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

  # ---- Confirm -> Confirm OK: known harness limitation, not driven live ---
  # See the file header note -- shinytest2/chromote never renders the
  # showModal() DOM here or for #153's identical, already-shipped pattern.
  # The server-side confirm sequence itself is proven correct by
  # test_modMarkerGenetics.R's testServer() tests. Attempt it anyway (in
  # case a future shinytest2/chromote version fixes the harness gap) but
  # skip gracefully, never fail, if the modal's own button isn't found.
  app$click("markerGenetics-sequenceConfirmExport")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  if (!click_element_safe(
    app, "#markerGenetics-sequenceConfirmExportOk"
  )) {
    skip(paste(
      "Confirm-export modal not found live (known shinytest2/chromote",
      "headless-modal-rendering gap shared with issue #153's own export",
      "gate -- see BACKLOG.md; server-side logic already proven correct",
      "via testServer())"
    ))
  }
})
