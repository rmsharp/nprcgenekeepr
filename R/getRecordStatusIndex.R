## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Returns record numbers with selected \code{recordStatus}.
#'
#' @param ped pedigree dataframe
#' @param status character vector with value of \code{"added"} or
#' \code{"original"}.
#' @return An integer vector of records with \code{recordStatus} ==
#' \code{status}.
#'
#' @noRd
getRecordStatusIndex <- function(ped, status = "added") {
  if (any("recordStatus" %in% names(ped))) {
    seq_along(ped$recordStatus)[ped$recordStatus == status]
  } else {
    integer(0L)
  }
}
