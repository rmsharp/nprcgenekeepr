## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Removes potential sires from list of Ids
#'
#' @param ids character vector of IDs of the animals
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
#' @param ped dataframe that is the `Pedigree`. It contains pedigree
#' information including the IDs listed in \code{candidates}.
#' @return character vector of Ids with any potential sire Ids removed.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' qcBreeders <- nprcgenekeepr::qcBreeders
#' pedWithGenotype <- nprcgenekeepr::pedWithGenotype
#' noSires <- removePotentialSires(
#'   ids = qcBreeders, minAge = 2,
#'   ped = pedWithGenotype
#' )
#' sires <- getPotentialSires(qcBreeders, ped = pedWithGenotype, minAge = 2)
#' pedWithGenotype[pedWithGenotype$id %in% noSires, c("sex", "age")]
#' pedWithGenotype[pedWithGenotype$id %in% sires, c("sex", "age")]
removePotentialSires <- function(ids, minAge, ped) {
  setdiff(ids, getPotentialSires(ids, ped, minAge))
}
