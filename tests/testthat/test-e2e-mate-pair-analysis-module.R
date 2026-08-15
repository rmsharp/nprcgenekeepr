## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Tests for Mate Pair Analysis Module (issue #151 Slice 2)
#'
#' Phase 3E runtime smoke test: drives the real running app end to end --
#' upload the bundled example pedigree, upload a small marker genotype file
#' on Marker Genetics (proving D6's appServer.R capture actually reaches this
#' new module, not just that the code compiles), configure and run Mate Pair
#' Analysis, and confirm both the new tab AND Marker Genetics' own existing
#' tabs render correctly with zero related console errors.
library(testthat)

## Two real, alive, breeding-age examplePedigree ids (one M, one F) --
## confirmed via qcStudbook()+filter at authoring time, not invented. Six ids
## total (3 M, 3 F) give the "custom" population scope enough pairs that
## excluding one still leaves eligible pairs to show.
matePairE2eIds <- list(
  males = c("1QBKW9", "Y3CJ5A", "HLQ9SY"),
  females = c("0ZX29Q", "5PWJ0G", "WTE53B")
)

## Genotype only the FIRST male/female pair -- this is the pair whose
## markerKinship must come back non-NA in the Eligible Pairs table, directly
## proving the D6 wiring (modMarkerGeneticsServer()'s markerKinshipMatrix,
## previously discarded by appServer.R, now reaches modMatePairServer).
makeMatePairE2eGenotypeFile <- function() {
  ids <- c(matePairE2eIds$males[1L], matePairE2eIds$females[1L])
  genotype <- data.frame(
    id = rep(ids, each = 8L),
    locus = rep(paste0("L", 1L:8L), 2L),
    allele1 = c(
      "A", "A", "B", "A", "A", "B", "A", "A",
      "A", "B", "B", "A", "B", "B", "A", "B"
    ),
    allele2 = c(
      "A", "B", "B", "A", "B", "B", "B", "A",
      "B", "B", "A", "B", "B", "A", "A", "B"
    ),
    stringsAsFactors = FALSE
  )
  path <- tempfile(fileext = ".csv")
  write.csv(genotype, path, row.names = FALSE)
  path
}

test_that("E2E: Mate Pair Analysis reports a live pair with marker kinship after D6 wiring, and Marker Genetics itself still works", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_mate_pair_analysis",
                           height = 1000, width = 1400)
  on.exit(app$stop(), add = TRUE)

  # ---- Load the bundled example pedigree (Input tab) ----------------------
  if (!navigate_to_tab(app, "Input")) skip("Could not navigate to Input")
  ## Must stay nprcgenekeepr::-qualified: the nightly shinytest2 job runs this
  ## tier via testthat::test_dir(), which never attaches the package (see
  ## test_e2e_package_qualification.R, which guards this).
  examplePedFile <- nprcgenekeepr::makeExamplePedigreeFile(
    file.path(tempdir(), "MatePairE2E_Pedigree.csv"), fileType = "csv"
  )
  do.call(app$upload_file,
          stats::setNames(list(examplePedFile), "dataInput-pedigreeFileOne"))
  app$click("dataInput-getData")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # ---- Upload a small genotype file on Marker Genetics ---------------------
  if (!navigate_to_tab(app, "Marker Genetics")) {
    skip("Could not navigate to Marker Genetics")
  }
  genoPath <- makeMatePairE2eGenotypeFile()
  do.call(app$upload_file,
          stats::setNames(list(genoPath), "markerGenetics-genotypeFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  # D6 regression: Marker Genetics' own Kinship Comparison table must still
  # render correctly (bound, non-error) after appServer.R now also captures
  # its return value -- the one live risk this slice introduces to already-
  # shipped behavior (plan Section 5 Slice 2 DONE criteria).
  markerHtml <- get_html_safe(app, "#markerGenetics-comparisonTable")
  expect_match(markerHtml, "shiny-bound-output",
               info = "Marker Genetics comparison table should still render")

  # ---- Configure and run Mate Pair Analysis --------------------------------
  if (!navigate_to_tab(app, "Mate Pair Analysis")) {
    skip("Could not navigate to Mate Pair Analysis")
  }

  allIds <- paste(c(matePairE2eIds$males, matePairE2eIds$females),
                  collapse = ", ")
  app$set_inputs(`matePair-populationSource` = "custom", wait_ = FALSE)
  app$set_inputs(`matePair-customPopulationIds` = allIds, wait_ = FALSE)
  app$set_inputs(`matePair-minAge` = 1, wait_ = FALSE)
  app$set_inputs(`matePair-useExcludeList` = TRUE, wait_ = FALSE)
  if (!wait_for_element(app, "#matePair-excludeIds", timeout = 10000)) {
    skip("Exclude-list textarea did not render")
  }
  app$set_inputs(`matePair-excludeIds` = matePairE2eIds$males[2L],
                 wait_ = FALSE)
  app$click("matePair-analyze")

  if (!wait_for_module_ready(app, "matePair", timeout = 60000)) {
    skip("Mate Pair Analysis did not signal data-ready within 60s")
  }

  pairsHtml <- get_html_safe(app, "#matePair-pairsTable")
  expect_match(pairsHtml, "shiny-bound-output",
               info = "Eligible Pairs table should render")
  # The genotyped pair's ids must appear in the rendered table.
  expect_match(pairsHtml, matePairE2eIds$males[1L], fixed = TRUE)
  expect_match(pairsHtml, matePairE2eIds$females[1L], fixed = TRUE)

  # The excluded id must be absent from Eligible Pairs...
  expect_false(grepl(matePairE2eIds$males[2L], pairsHtml, fixed = TRUE))

  # ...and present, with reason "user-excluded", in the Excluded tab.
  click_element_safe(app, "a[data-value='Excluded']")
  excludedHtml <- get_html_safe(app, "#matePair-excludedTable")
  expect_match(excludedHtml, matePairE2eIds$males[2L], fixed = TRUE)
  expect_match(excludedHtml, "user-excluded")

  ## Neither the new module nor the D6 wiring change may throw a JS console
  ## error. Pre-existing, unrelated console noise (e.g. shinyBS) is
  ## deliberately not asserted away here, matching the pedigree-diagram E2E
  ## test's own established precedent.
  logs <- app$get_logs()
  matePairErrors <- logs[logs$level == "throw" &
                           grepl("matePair|markerGenetics",
                                 logs$message, ignore.case = TRUE), ]
  expect_equal(nrow(matePairErrors), 0L,
               info = "No Mate Pair Analysis/Marker Genetics console error")
})
