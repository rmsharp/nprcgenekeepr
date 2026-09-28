## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Rebuild inst/extdata/examples/ExamplePedigree.txt from
#' inst/extdata/examples/ExamplePedigree.csv (BACKLOG.md item found S800;
#' rebuilt S801).
#'
#' The .txt is the tab-delimited copy of the same 3,694 animals, and the only
#' text-format example shipped under inst/extdata, so it is the file a user
#' can try the app's text upload with. The earlier copy had been saved
#' through Excel: every recorded age became Excel's date display of the
#' number (7.8 as "1900-01-07", an age under 1 as "1900-01-00", a negative
#' age as "#####") and the id "15FEBR" became "15-Feb".
#'
#' Every cell is read as the text the CSV holds ("NA" stays "NA", a blank
#' stays blank) and written tab-separated and unquoted, so the .txt holds the
#' same cells as the .csv. tests/testthat/test_examplePedigreeTxt.R checks
#' that. Re-run this script whenever ExamplePedigree.csv changes.
#'
#' Run from the package root:
#'   Rscript data-raw/ExamplePedigree_txt.R

examplesDir <- file.path("inst", "extdata", "examples")

ped <- read.csv(
  file.path(examplesDir, "ExamplePedigree.csv"),
  colClasses = "character", na.strings = character(0L)
)

write.table(
  ped,
  file.path(examplesDir, "ExamplePedigree.txt"),
  sep = "\t", quote = FALSE, row.names = FALSE, eol = "\n"
)
