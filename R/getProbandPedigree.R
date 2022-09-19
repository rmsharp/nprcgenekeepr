#' Gets pedigree to ancestors of provided group leaving uninformative ancestors.
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Filters a pedigree down to only the ancestors of the provided group,
#' removing unnecessary individuals from the studbook. This version builds
#' the pedigree back in time starting from a group of probands. This will
#' include all ancestors of the probands, even ones that might be
#' uninformative.
#'
#' @return A reduced pedigree.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedWithGenotype
#' ids <- nprcgenekeepr::qcBreeders
#' sires <- getPotentialSires(ids, minAge = 1, ped)
#' head(getProbandPedigree(probands = sires, ped = ped))
#' }
#'
#' @param probands a character vector with the list of animals whose ancestors
#' should be included in the final pedigree.
#' @param ped datatable that is the `Pedigree`. It contains pedigree
#' information. The fields \code{sire} and \code{dam} are required.
#' @export
getProbandPedigree <- function(probands, ped) {
  while (TRUE) {
    sires <- ped$sire[ped$id %in% probands]
    dams <- ped$dam[ped$id %in% probands]

    parents <- unique(union(sires, dams))
    parents <- parents[!is.na(parents)]
    added <- setdiff(parents, probands)
    if (length(added) == 0)
      break
    probands <- union(probands, parents)
  }

  ped <- ped[ped$id %in% probands, ]
  return(ped)
}
