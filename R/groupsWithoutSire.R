## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Which harem groups have no seeded sire
#'
#' A harem group whose current animals include a male at least \code{minAge}
#' old keeps him as its sire. Every other group needs a sire to be chosen for
#' it.
#'
#' @param numGp integer value indicating the number of groups to be formed.
#' @param currentGroups list of character vectors of IDs of animals currently
#' assigned to each group. A group beyond \code{length(currentGroups)} has no
#' current animals.
#' @inheritParams getPotentialSires
#' @param minAge integer value indicating the minimum age of a sire.
#' @return Logical vector of length \code{numGp}, \code{TRUE} for each group
#' whose current animals include no male at least \code{minAge} old.
#'
#' @noRd
groupsWithoutSire <- function(numGp, currentGroups, ped, minAge) {
  vapply(seq_len(numGp), function(i) {
    seeds <- if (i <= length(currentGroups)) {
      currentGroups[[i]]
    } else {
      character(0L)
    }
    length(getPotentialSires(seeds, ped, minAge)) == 0L
  }, logical(1L))
}
