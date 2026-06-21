#' Get a focal-animal pedigree from a pedigree file (offline, no database)
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' File-sourced sibling of \code{\link{getFocalAnimalPed}}: reads a list of
#' focal animal Ids from \code{fileName} (the first column, exactly as
#' \code{\link{getFocalAnimalPed}} does), then builds the focal animals' full
#' connected pedigree component from a SEPARATE pedigree file via
#' \code{\link{getFileDirectRelatives}}. This lets the focal-animal workflow run
#' entirely offline -- no LabKey / EHR connection is required.
#'
#' The underlying file source errors loudly on a bad pedigree file, but this
#' function is the application boundary, so it is fail-soft: it returns
#' \code{NULL} when the pedigree file is missing, does not exist, or lacks the
#' \code{id}, \code{sire}, and \code{dam} columns. (This mirrors how the app's
#' other file inputs behave -- a \code{NULL} surfaces a "File Read Error" -- and
#' is distinct from the LabKey path, which returns an \code{nprcgenekeeprErr}.)
#'
#' @return A data.frame with the focal animals' full connected pedigree
#' component (ancestors, descendants, and collaterals), as returned by
#' \code{\link{getFileDirectRelatives}}; or \code{NULL} if the pedigree file
#' cannot be read.
#'
#' @param fileName character path to a file (CSV, delimited text, or Excel)
#' whose first column is the list of focal animal Ids.
#' @param pedigreeFileName character path to the pedigree file (CSV, delimited
#' text, or Excel) read via \code{\link{getPedigree}}; it must provide at least
#' \code{id}, \code{sire}, and \code{dam} columns.
#' @param sep column separator passed to the file readers for delimited text
#' files (default \code{","}); ignored for Excel files.
#' @import futile.logger
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## A focal-id file and a pedigree file, then build the pedigree offline.
#' ped <- data.frame(
#'   id = c("A", "B", "C"), sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
#'   stringsAsFactors = FALSE
#' )
#' pedFile <- tempfile(fileext = ".csv")
#' write.csv(ped, pedFile, row.names = FALSE)
#' focalFile <- tempfile(fileext = ".csv")
#' write.csv(data.frame(id = "C"), focalFile, row.names = FALSE)
#' getFocalAnimalPedFromFile(focalFile, pedFile)
#' unlink(c(pedFile, focalFile))
getFocalAnimalPedFromFile <- function(fileName, pedigreeFileName = NULL,
                                      sep = ",") {
  flog.debug("in getFocalAnimalPedFromFile\n", name = "nprcgenekeepr")
  ids <- readFocalAnimalIds(fileName, sep = sep)
  tryCatch(
    getFileDirectRelatives(ids = ids, fileName = pedigreeFileName, sep = sep),
    error = function(e) {
      flog.debug(
        paste0("getFocalAnimalPedFromFile: pedigree file could not be read: ",
               conditionMessage(e), "\n"),
        name = "nprcgenekeepr"
      )
      NULL
    }
  )
}
