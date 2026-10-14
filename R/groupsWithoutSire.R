## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' The animals currently assigned to each of the groups to be formed
#'
#' @param numGp integer value indicating the number of groups to be formed.
#' @param currentGroups list of character vectors of IDs of animals currently
#' assigned to each group.
#' @return List of length \code{numGp}: element \code{i} is
#' \code{currentGroups[[i]]}, or \code{character(0)} for a group beyond
#' \code{length(currentGroups)}.
#'
#' @noRd
groupSeeds <- function(numGp, currentGroups) {
  lapply(seq_len(numGp), function(i) {
    if (i <= length(currentGroups)) currentGroups[[i]] else character(0L)
  })
}

#' Which harem groups have no seeded sire
#'
#' A harem group whose current animals include a male at least \code{minAge}
#' old keeps him as its sire. Every other group needs a sire to be chosen for
#' it.
#'
#' @inheritParams groupSeeds
#' @inheritParams getPotentialSires
#' @param minAge integer value indicating the minimum age of a sire.
#' @return Logical vector of length \code{numGp}, \code{TRUE} for each group
#' whose current animals include no male at least \code{minAge} old.
#'
#' @noRd
groupsWithoutSire <- function(numGp, currentGroups, ped, minAge) {
  vapply(groupSeeds(numGp, currentGroups), function(seeds) {
    length(getPotentialSires(seeds, ped, minAge)) == 0L
  }, logical(1L))
}
