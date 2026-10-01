## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' List each animal's high-kinship relatives
#'
#' @inheritParams meanKinship
#' @inheritParams reportGV
#' @inheritParams filterThreshold
#' @param currentGroups list of character vectors of IDs of animals currently
#' assigned
#' to the group. Required (no default); use \code{character(0L)} when
#' no groups exist.
#' @param ignore list of character vectors representing the sex combinations
#' to be ignored. If provided, the vectors in the list specify if pairwise
#' kinship should be ignored between certain sexes. Required (no default);
#' \code{filterPairs()} itself ignores female-female pairs when called
#' directly.
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Required (no default). Pairwise kinships involving an animal
#' younger than this age are ignored; animals of exactly this age or with a
#' missing age are retained.
#'
#' @return A one-dimensional array of mode list (from \code{tapply()}), not a
#' plain list. Its names are animal IDs, and each element is a character
#' vector of animals sharing a kinship value greater than or equal to the
#' \code{threshold} value. \code{names()} and \code{[[} work as for a list.
#'
#' @export
#' @examples
#' qcPed <- nprcgenekeepr::qcPed
#' ped <- qcStudbook(qcPed,
#'   minSireAge = 2L, minDamAge = 2L, reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
#' currentGroups <- list(1L)
#' currentGroups[[1L]] <- examplePedigree$id[1L:3L]
#' candidates <- examplePedigree$id[examplePedigree$status == "ALIVE"]
#' threshold <- 0.015625
#' kin <- getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups,
#'   ignore = list(c("F", "F")), minAge = 1.0
#' )
#' length(kin) # should be 259
#' kin[["0DAV0I"]] # should have 34 IDs
getAnimalsWithHighKinship <- function(kmat, ped, threshold, currentGroups,
                                      ignore, minAge) {
  kin <- kinMatrix2LongForm(kmat)

  kin <- filterThreshold(kin, threshold = threshold)
  kin <- filterPairs(kin, ped, ignore = ignore)
  kin <- filterAge(kin, ped, minAge = minAge)

  # Filter out self kinships
  kin <- kin[(kin$id1 != kin$id2), ]

  # Ignore kinship between current group members
  kin <- kin[!((kin$id1 %in% unlist(currentGroups)) &
    (kin$id2 %in% unlist(currentGroups))), ]

  # Converting the kinships to a list
  kin <- tapply(kin$id2, kin$id1, c)
  kin
}
