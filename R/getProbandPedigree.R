## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Reduce a pedigree to probands and their ancestors
#'
#' Filters a pedigree down to the provided group (the probands) together
#' with all of their ancestors, removing unnecessary individuals from the
#' studbook. This version builds
#' the pedigree back in time starting from a group of probands. This will
#' include all ancestors of the probands, even ones that might be
#' uninformative.
#'
#' @param probands a character vector with the list of animals whose ancestors
#' should be included in the final pedigree.
#' @inheritParams trimPedigree
#' @return A reduced pedigree.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::pedWithGenotype
#' ids <- nprcgenekeepr::qcBreeders
#' sires <- getPotentialSires(ids, ped, minAge = 1)
#' head(getProbandPedigree(probands = sires, ped = ped))
getProbandPedigree <- function(probands, ped) {
  probands <- unlist(walkPedigree(probands, ped, "ancestors"))
  ped <- ped[ped$id %in% probands, ]
  ped
}
