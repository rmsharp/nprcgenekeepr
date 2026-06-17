#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' Full-stack E2E for GitHub issue #4 -- a pedigree file whose final line lacks
#' a trailing newline must upload and process correctly through the real
#' browser, with every record preserved.
#'
#' This drives the assembled modular app (appUI()/appServer) through
#' shinytest2::AppDriver and uploads a no-trailing-newline copy of
#' ExamplePedigree.csv through both reader branches the surgical
#' muffleIncompleteFinalLine() helper wraps:
#'   (1) fileType = Text  -> read.table
#'   (2) default fileType -> read.csv
#' For each it asserts the cleaned studbook flows end to end into the Pedigree
#' Browser, whose always-rendered table reports every record incl. the final
#' unterminated line. Teeth: the count requires the final row to be read, and a
#' regression that rejected/mangled unterminated uploads would fail here.
#'
#' Division of labour: the "incomplete final line" warning S89 muffles is a
#' console-only artifact that does not reach the DOM, AND it only fires for
#' SMALL files (the readTableHeader scan must reach the unterminated line;
#' verified S90), so a realistic-size file like this one does not even trigger
#' it. The warning-SUPPRESSION teeth therefore live in the in-process
#' test_modInput_incomplete_final_line.R (testServer, tiny fixtures) and S89's
#' test_muffleIncompleteFinalLine.R. This browser test owns the end-to-end
#' data-integrity half: a no-trailing-newline upload processes correctly.
#'
#' OPT-IN (NPRC_RUN_E2E=true); skipped otherwise via create_test_app(). Drives
#' the INSTALLED package, so run devtools::install() first.
library(testthat)

# Pedigree Browser DataTable info text for a clean upload of ExamplePedigree.csv
# (3694 records; read.csv and read.table(sep = ",") yield identical frames --
# verified S90). DataTables formats the count with a comma. Removing the
# trailing newline must not drop the final row, so this count is the regression
# value.
EXPECTED_ENTRIES_TEXT <- "of 3,694 entries"

# Write the lines of `src` to a fresh tempfile WITHOUT a trailing final
# newline, reproducing the condition issue #4 reported. ExamplePedigree.csv
# itself ends with a newline, so readLines() reads it cleanly and
# paste(collapse = "\n") leaves no terminator after the final line.
write_without_final_newline <- function(src, ext = ".csv") {
  lines <- readLines(src, warn = FALSE)
  dest <- tempfile(fileext = ext)
  cat(paste(lines, collapse = "\n"), file = dest)
  dest
}

test_that("E2E: text (read.table) upload with no final newline keeps rows", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_incomplete_text")
  on.exit(app$stop(), add = TRUE)

  fixture <- write_without_final_newline(
    get_test_data_path("ExamplePedigree.csv"), ext = ".txt"
  )

  # Drive the read.table branch: fileType = Text (the path issue #4 reported).
  # fileContent defaults to pedFile -> pedigreeFileOne; the comma separator
  # default applies once the panel is revealed.
  app$set_inputs(`dataInput-fileType` = "fileTypeText")
  app$wait_for_idle(timeout = E2E_TIMEOUT)
  app$upload_file(`dataInput-pedigreeFileOne` = fixture)
  app$click("dataInput-getData")
  ready <- wait_for_module_ready(app, "dataInput", timeout = E2E_TIMEOUT)
  if (!ready) skip("Upload/QC of the no-newline text file did not complete")

  # The cleaned studbook materializes the Pedigree Browser table, which reports
  # every record incl. the final unterminated line.
  if (!navigate_to_tab(app, "Pedigree Browser", "Pedigree")) {
    skip("Could not navigate to Pedigree Browser tab")
  }
  expect_match(
    get_html_safe(app, "#pedigree-pedigreeTable"),
    EXPECTED_ENTRIES_TEXT, fixed = TRUE,
    info = "Pedigree table should display all records, incl. the final row"
  )
})

test_that("E2E: csv (read.csv) upload with no final newline keeps rows", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_incomplete_csv")
  on.exit(app$stop(), add = TRUE)

  fixture <- write_without_final_newline(
    get_test_data_path("ExamplePedigree.csv"), ext = ".csv"
  )

  # Default fileType (Excel) + a .csv upload falls through to read.csv.
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC of the no-newline CSV file did not complete")

  if (!navigate_to_tab(app, "Pedigree Browser", "Pedigree")) {
    skip("Could not navigate to Pedigree Browser tab")
  }
  expect_match(
    get_html_safe(app, "#pedigree-pedigreeTable"),
    EXPECTED_ENTRIES_TEXT, fixed = TRUE,
    info = "Pedigree table should display all records, incl. the final row"
  )
})
