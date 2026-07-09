## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Remove IDs having UNKNOWN regardless of case
#'
#' Someone started entering "unknown" for unknown parents instead of leaving
#' the field blank in PRIMe.
#' @param ped  A dataframe containing at least and "id" field
#' @return A dataframe with "UNKNOWN" values in the columns \code{id},
#' \code{sire}, and \code{dam} replaced with NA
#' @noRd
unknown2NA <- function(ped) {
  if ("id" %in% names(ped)) {
    ped <- ped[toupper(ped$id) != "UNKNOWN", ]
  }
  if ("sire" %in% names(ped)) {
    ped$sire[toupper(ped$sire) == "UNKNOWN"] <- NA
  }
  if ("dam" %in% names(ped)) {
    ped$dam[toupper(ped$dam) == "UNKNOWN"] <- NA
  }
  ped
}
