## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Update or add the "group" field of a Pedigree.
#'
#' Part of the pedigree filtering toolset
#'
#' @param ped datatable that is the \code{Pedigree}. It contains pedigree
#' information. The \code{id} column is required.
#' @param ids character vector of IDs to be flagged as part of the group under
#' consideration.
#' @return An updated pedigree with the \code{group} column added or updated
#' by being set to \code{TRUE} for the animal IDs in \code{ped$id} and
#' \code{FALSE} otherwise.
#'
#' @noRd
resetGroup <- function(ped, ids) {
  ped$group <- FALSE
  ped$group[ped$id %in% ids] <- TRUE
  ped
}
