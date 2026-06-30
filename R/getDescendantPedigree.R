## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Gets pedigree with descendants of provided group
#'
#' Filters a pedigree down to only the descendants of the provided group,
#' building the pedigree forward in time starting from a group of probands.
#' This is the downward (descendants-only) mirror of
#' \code{\link{getProbandPedigree}}: it takes the transitive closure over
#' offspring and returns the probands together with all of their descendants.
#' It does not include collateral relatives (siblings, cousins, or mates).
#'
#' @return A reduced pedigree containing the probands and all of their
#' descendants.
#'
#' @param probands a character vector with the list of animals whose
#' descendants should be included in the final pedigree.
#' @param ped datatable that is the `Pedigree`. It contains pedigree
#' information. The fields \code{id}, \code{sire} and \code{dam} are required.
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' ## D's descendants are F and G
#' getDescendantPedigree(probands = "D", ped = ped)$id
getDescendantPedigree <- function(probands, ped) {
  repeat {
    offspring <- getOffspring(ped, probands)
    added <- setdiff(offspring, probands)
    if (length(added) == 0L) {
      break
    }
    probands <- union(probands, offspring)
  }

  ped <- ped[ped$id %in% probands, ]
  ped
}
