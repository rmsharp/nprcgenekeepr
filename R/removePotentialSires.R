#' Removes potential sires from list of Ids
#'
## Copyright(c) 2017-2023 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#'  @return character vector of Ids with any potential sire Ids removed.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' qcBreeders <- nprcgenekeepr::qcBreeders
#' pedWithGenotype <- nprcgenekeepr::pedWithGenotype
#' noSires <- removePotentialSires(ids = qcBreeders, minAge = 2,
#'                                 ped = pedWithGenotype)
#' sires <- getPotentialSires(qcBreeders, minAge = 2, ped = pedWithGenotype)
#' pedWithGenotype[pedWithGenotype$id %in% noSires, c("sex", "age")]
#' pedWithGenotype[pedWithGenotype$id %in% sires, c("sex", "age")]
#' }
#'
#' @param ids character vector of IDs of the animals
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
#' @param ped dataframe that is the `Pedigree`. It contains pedigree
#' information including the IDs listed in \code{candidates}.
#' @export
removePotentialSires <- function(ids, minAge, ped) {
  setdiff(ids, getPotentialSires(ids, minAge, ped))
}
