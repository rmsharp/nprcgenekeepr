## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support (S905): the bundled rhesus pedigree as the app's QC
## step delivers it. The live app lays out the QC'd pedigree, never the raw
## CSV: modInput runs runQcStudbook() first, and that step reorders the rows,
## which moves the rectilinear waypoint count (BACKLOG row-order item).

#' The bundled rhesus pedigree after the app's QC step
#'
#' Reads \code{obfuscated_rhesus_mhc_ped.csv} and runs it through
#' \code{runQcStudbook()} the way \code{modInputServer} does (blank age floors,
#' so the species and sex default applies; \code{reportChanges = TRUE}).
#'
#' @return The \code{cleaned} data frame: the same 375 animals as the CSV, in
#'   the QC step's row order.
qcdRhesusPed <- function() {
  raw <- read.csv(
    system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE
  )
  suppressWarnings(suppressMessages(
    runQcStudbook(raw, minSireAge = NULL, minDamAge = NULL,
                  reportChanges = TRUE)
  ))$cleaned
}
