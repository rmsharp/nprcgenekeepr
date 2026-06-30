## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get a focal-animal pedigree from a pedigree file (offline, no database)
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
#' @return On success, a data.frame with the focal animals' full connected
#' pedigree component (ancestors, descendants, and collaterals), as returned by
#' \code{\link{getFileDirectRelatives}}. On any failure this function does NOT
#' throw: it returns a classed \code{nprcgenekeeprFileErr} object (a list with a
#' \code{message} element) naming WHY the read failed -- an unreadable focal-id
#' list file; a missing, not-found, unreadable, or wrong-column pedigree file;
#' or no focal IDs present in the pedigree. The application surfaces
#' \code{message} as the "File Read Error" detail (distinct from the LabKey
#' path, which returns an \code{nprcgenekeeprErr}).
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

  ids <- tryCatch(
    readFocalAnimalIds(fileName, sep = sep),
    error = function(e) {
      flog.debug(
        paste0("getFocalAnimalPedFromFile: focal-id list file could not be ",
               "read: ", conditionMessage(e), "\n"),
        name = "nprcgenekeepr"
      )
      nprcgenekeeprFileErr("The focal animal ID list file could not be read.")
    }
  )
  if (inherits(ids, "nprcgenekeeprFileErr")) {
    return(ids)
  }

  rel <- tryCatch(
    getFileDirectRelatives(ids = ids, fileName = pedigreeFileName, sep = sep),
    error = function(e) {
      flog.debug(
        paste0("getFocalAnimalPedFromFile: pedigree file could not be read: ",
               conditionMessage(e), "\n"),
        name = "nprcgenekeepr"
      )
      nprcgenekeeprFileErr(pedigreeReadReason(conditionMessage(e)))
    }
  )
  if (inherits(rel, "nprcgenekeeprFileErr")) {
    return(rel)
  }

  if (is.data.frame(rel) && nrow(rel) == 0L) {
    return(nprcgenekeeprFileErr(
      "None of the focal IDs were found in the pedigree file."
    ))
  }
  rel
}

#' Construct a file-read error object for the offline focal-animal path
#'
#' @param message character user-facing reason the file read failed.
#' @return A list with a \code{message} element and class
#' \code{nprcgenekeeprFileErr}.
#' @noRd
nprcgenekeeprFileErr <- function(message) {
  err <- list(message = message)
  class(err) <- "nprcgenekeeprFileErr"
  err
}

#' Map a low-level pedigree-read error to a user-facing reason
#'
#' Translates the condition message thrown by the file pedigree source
#' (\code{getPedigreeSource(sourceType = "file")} via \code{getPedigree}) into a
#' concise, user-facing explanation for the application's "File Read Error".
#'
#' @param msg character condition message from the failed read.
#' @return character single user-facing reason.
#' @noRd
pedigreeReadReason <- function(msg) {
  if (grepl("must be supplied", msg, fixed = TRUE)) {
    "A pedigree file must be supplied to build the focal pedigree offline."
  } else if (grepl("not found", msg, fixed = TRUE)) {
    "Pedigree file not found."
  } else if (grepl("must contain columns", msg, fixed = TRUE)) {
    "The pedigree file must contain columns id, sire, and dam."
  } else {
    "The pedigree file could not be read."
  }
}
