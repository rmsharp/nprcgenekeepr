## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' List potential sires
#'
#' @inheritParams getParents
#' @param ped dataframe that is the \code{Pedigree}. It contains pedigree
#' information including the IDs listed in \code{ids}.
#' @param minAge integer value giving the inclusive minimum current age (in
#' years) a male must have to be listed as a potential sire. Default is 1
#' year.
#' @return A character vector of potential sire Ids
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedWithGenotype
#' ids <- nprcgenekeepr::qcBreeders
#' getPotentialSires(ids, ped, minAge = 1L)
getPotentialSires <- function(ids, ped, minAge = 1L) {
  ped <- ped[!is.na(ped$birth), ]
  ped$id[ped$id %in% ids & ped$sex == sexCodes[["male"]] &
    getCurrentAge(ped$birth) >= minAge &
    !is.na(ped$birth)]
}
