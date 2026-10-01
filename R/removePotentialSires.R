## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Remove potential sires from a list of IDs
#'
#' @inheritParams getParents
#' @inheritParams getPotentialSires
#' @param minAge integer value giving the inclusive minimum current age (in
#' years) a male must have to be listed as a potential sire. Unlike
#' \code{getPotentialSires}, there is no default; it is required.
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
