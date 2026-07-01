## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' List potential sires
#'
#' @param ids character vector of IDs of the animals
#' @param ped dataframe that is the \code{Pedigree}. It contains pedigree
#' information including the IDs listed in \code{candidates}.
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#' be ignored. Default is 1 year.
#' @return A character vector of potential sire Ids
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedWithGenotype
#' ids <- nprcgenekeepr::qcBreeders
#' getPotentialSires(ids, ped, minAge = 1)
getPotentialSires <- function(ids, ped, minAge = 1L) {
  ped <- ped[!is.na(ped$birth), ]
  ped$id[ped$id %in% ids & ped$sex == "M" & getCurrentAge(ped$birth) >= minAge &
    !is.na(ped$birth)]
}
