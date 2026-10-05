## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Remove duplicate records from pedigree
#'
#' Part of Pedigree Curation
#'
#' Returns an updated dataframe with duplicate rows removed.
#'
#' Returns an error if the table has duplicate IDs with differing data. The
#' error applies only when \code{reportErrors} is \code{FALSE}. Rows are
#' compared on all columns, including \code{recordStatus}.
#'
#' @param ped dataframe that is the \code{Pedigree}. It contains pedigree
#' information. The \code{id} and \code{recordStatus} columns are required.
#' @param reportErrors logical value if TRUE the function returns a
#' character vector of duplicate \code{id} values (or \code{NULL} when none
#' are found) instead of the de-duplicated pedigree. Only records whose
#' \code{recordStatus} is \code{"added"} (the records made for parents that
#' have no record of their own) are left out of the search; a record with
#' any other \code{recordStatus}, including \code{NA} or a blank, is a real
#' animal and is searched.
#' @return When \code{reportErrors} is \code{FALSE}, a dataframe (the
#' \code{Pedigree}) with duplicate rows removed; when \code{reportErrors} is
#' \code{TRUE}, a character vector of duplicate \code{id} values, one entry
#' for each extra occurrence of an \code{id} (or \code{NULL} when none are
#' found).
#'
#' @export
#' @examples
#' ped <- nprcgenekeepr::smallPed
#' newPed <- cbind(ped, recordStatus = rep("original", nrow(ped)))
#' ped1 <- removeDuplicates(newPed)
#' nrow(newPed)
#' nrow(ped1)
#' pedWithDups <- rbind(newPed, newPed[1:3, ])
#' ped2 <- removeDuplicates(pedWithDups)
#' nrow(pedWithDups)
#' nrow(ped2)
removeDuplicates <- function(ped, reportErrors = FALSE) {
  if (!all(c("id", "recordStatus") %in% names(ped))) {
    stop("ped must have columns \"id\" and \"recordStatus\".")
  }
  if (reportErrors) {
    ## isAddedRecord() says which records are set aside. The ids come from the
    ## remaining rows alone, so no logical mask shorter than ped$id is recycled
    ## over the added rows.
    isAdded <- isAddedRecord(ped$recordStatus)
    ids <- ped$id[!isAdded]
    if (anyDuplicated(ids) > 0L) {
      ids[duplicated(ids)]
    } else {
      NULL
    }
  } else {
    p <- unique(ped)
    if (anyDuplicated(p$id) > 0L) {
      stop("Duplicate IDs with mismatched information present")
    }
    p
  }
}
