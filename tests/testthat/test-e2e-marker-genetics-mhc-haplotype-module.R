## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Test for the Marker Genetics "MHC Haplotype Reporting" Tab (issue
#' #148 Slice 4)
#'
#' Phase 3E runtime smoke test: drives the real running app end to end with
#' the bundled real data pair -- load obfuscated_rhesus_mhc_ped.csv (375
#' animals, a superset of the MHC file's 31 genotyped ids, so the export's
#' pedigree-only alias map covers every carrier -- plan Dragon 5), upload
#' obfuscated_rhesus_mhc_breeder_genotypes.csv through the tab's OWN
#' dedicated mhcHaplotypeFile input (plan D2/D8), confirm the summary and
#' rare-carrier tables, the counts/denominator line, the pedigree-coverage
#' line and the persistent caveat render, then drive the full curator-gated
#' export -- Generate Preview -> Confirm Export -> modal -> Confirm Export
#' OK -- and download all three artifacts (summary, de-identified carrier
#' list, manifest), with zero related console errors (plan sec 5 Slice 4
#' "Done when"). Every step is a hard assertion, not a self-skip: a missing
#' tab or control must fail this test, not quietly pass it.
library(testthat)

test_that("E2E: Marker Genetics' MHC Haplotype Reporting tab reports the bundled file and exports all three de-identified artifacts", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_marker_genetics_mhc_haplotype",
                           height = 1000, width = 1400)
  on.exit(app$stop(), add = TRUE)

  mhcFile <- get_test_data_path("obfuscated_rhesus_mhc_breeder_genotypes.csv")
  mhcIds <- utils::read.csv(mhcFile, stringsAsFactors = FALSE)$id

  # ---- Load the bundled pedigree (covers all 31 MHC-file animals) -------
  expect_true(navigate_to_tab(app, "Input"))
  pedFile <- get_test_data_path("obfuscated_rhesus_mhc_ped.csv")
  do.call(app$upload_file,
          stats::setNames(list(pedFile), "dataInput-pedigreeFileOne"))
  app$click("dataInput-getData")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  qcErrorsText <- get_html_safe(app, "#dataInput-qcErrors")
  expect_false(grepl("Missing required column", qcErrorsText, fixed = TRUE))

  # ---- Open the MHC tab and upload through its dedicated input ----------
  expect_true(navigate_to_tab(app, "Marker Genetics"))
  expect_true(click_element_safe(
    app, "a[data-value='MHC Haplotype Reporting']"
  ))
  do.call(app$upload_file,
          stats::setNames(list(mhcFile), "markerGenetics-mhcHaplotypeFile"))
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  expect_true(wait_for_dt_rendered(app, "#markerGenetics-mhcSummaryTable",
                                   timeout = E2E_TIMEOUT))
  summaryHtml <- get_html_safe(app, "#markerGenetics-mhcSummaryTable")
  expect_match(summaryHtml, "A004_B002", fixed = TRUE)
  expect_true(wait_for_dt_rendered(app, "#markerGenetics-mhcCarrierTable",
                                   timeout = E2E_TIMEOUT))

  countsHtml <- get_html_safe(app, "#markerGenetics-mhcCountsSummary")
  expect_match(countsHtml, "60 certain", fixed = TRUE)
  coverageHtml <- get_html_safe(app, "#markerGenetics-mhcPedigreeCoverage")
  expect_match(coverageHtml, "31 of 375", fixed = TRUE)
  paneHtml <- get_html_safe(
    app, ".tab-pane[data-value='MHC Haplotype Reporting']"
  )
  expect_match(paneHtml, "performs no MHC inference", fixed = TRUE)

  ## D8: the MHC upload never feeds the shared marker genotype input, so
  ## the Kinship Comparison tab still asks for a marker genotype file.
  guidanceHtml <- get_html_safe(app, "#markerGenetics-guidance")
  expect_match(guidanceHtml, "Upload a marker genotype file", fixed = TRUE)

  # ---- Preview -> Confirm -> Confirm OK, driven live ---------------------
  exportGuidanceBefore <- get_html_safe(app,
                                        "#markerGenetics-mhcExportGuidance")
  expect_match(exportGuidanceBefore, "alert-info", fixed = TRUE)
  app$click("markerGenetics-mhcExportPreview")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  app$click("markerGenetics-mhcConfirmExport")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  expect_true(wait_for_element(app, "#markerGenetics-mhcConfirmExportOk",
                               timeout = E2E_TIMEOUT))
  app$click(selector = "#markerGenetics-mhcConfirmExportOk")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  exportGuidanceAfter <- get_html_safe(app,
                                       "#markerGenetics-mhcExportGuidance")
  expect_false(grepl("alert", exportGuidanceAfter, fixed = TRUE))

  # ---- All three artifacts download, de-identified ----------------------
  summaryCsv <- utils::read.csv(
    app$get_download("markerGenetics-downloadMhcSummary"),
    stringsAsFactors = FALSE
  )
  expect_identical(nrow(summaryCsv), 33L)
  carriersCsv <- utils::read.csv(
    app$get_download("markerGenetics-downloadMhcCarriers"),
    stringsAsFactors = FALSE
  )
  expect_identical(nrow(carriersCsv), 32L)
  expect_false(any(carriersCsv$id %in% mhcIds))
  manifestCsv <- utils::read.csv(
    app$get_download("markerGenetics-downloadMhcManifest"),
    stringsAsFactors = FALSE
  )
  expect_identical(nrow(manifestCsv), 1L)
  expect_identical(as.integer(manifestCsv$denominator), 60L)

  ## Pre-existing, unrelated console noise (e.g. shinyBS) is deliberately
  ## not asserted away, matching the Genomic ROH E2E test's precedent.
  logs <- app$get_logs()
  mhcErrors <- logs[logs$level == "throw" &
                      grepl("markerGenetics", logs$message,
                            ignore.case = TRUE), ]
  expect_identical(nrow(mhcErrors), 0L)
})
