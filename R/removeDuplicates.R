## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Remove duplicate records from pedigree
#'
#' Part of Pedigree Curation
#'
#' Returns an updated dataframe with duplicate rows removed.
#'
#' Returns an error if the table has duplicate IDs with differing data.
#'
#' @param ped dataframe that is the \code{Pedigree}. It contains pedigree
#' information. The \code{id} column is required.
#' @param reportErrors logical value if TRUE will scan the entire file and
#' make a list of all errors found. The errors will be returned in a
#' list of list where each sublist is a type of error found.
#' @return Pedigree object with all duplicates removed.
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
    if (anyDuplicated(ped$id[ped$recordStatus == "original"]) > 0L) {
      ped$id[duplicated(ped$id[ped$recordStatus == "original"])]
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
