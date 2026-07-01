## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Make the initial groupMembers animal list
#'
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @param currentGroups list of character vectors of IDs of animals currently
#' assigned to the group. Defaults to character(0) assuming no groups are
#' existent.
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @param ped dataframe that is the \code{Pedigree}. It contains pedigree
#' information including the IDs listed in \code{candidates}.
#' @param harem logical variable when set to \code{TRUE}, the formed groups
#' have a single male at least \code{minAge} old.
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
#' @return Initial groupMembers list
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::qcPed
#' candidates <- nprcgenekeepr::qcBreeders
#' ## Non-harem: pre-seed group 1 with animals already assigned; a
#' ## second, empty group is initialized ready to be filled.
#' currentGroups <- list(candidates[1L:3L])
#' groupMembers <- makeGroupMembers(
#'   numGp = 2L, currentGroups = currentGroups, candidates = candidates,
#'   ped = ped, harem = FALSE, minAge = 1L
#' )
#' groupMembers
#' ## Harem: each group is seeded with one available male (uses sample()).
#' set.seed(1L)
#' haremMembers <- makeGroupMembers(
#'   numGp = 2L, currentGroups = list(), candidates = candidates,
#'   ped = ped, harem = TRUE, minAge = 1L
#' )
#' haremMembers
makeGroupMembers <- function(numGp, currentGroups, candidates, ped, harem,
                             minAge) {
  groupMembers <- list()
  if (harem) {
    ## Since harems only have a single male, they are inserted during
    ## initialization.
    groupMembers <- initializeHaremGroups(
      numGp, currentGroups, candidates,
      ped, minAge
    )
  } else {
    for (i in seq_len(numGp)) {
      if (length(currentGroups) >= i) {
        groupMembers[[i]] <- currentGroups[[i]]
      } else {
        groupMembers[[i]] <- vector()
      }
    }
  }
  groupMembers
}
