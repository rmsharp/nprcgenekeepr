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
#' @inheritParams getPotentialSires
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
#' @return Initial groupMembers list: the set-up groupAddAssign() builds once
#' per call (\code{makeHaremSetUp()}) and the draw of the sires each trial
#' makes (\code{drawHaremGroups()}).
#'
#' @noRd
initializeHaremGroups <- function(numGp, currentGroups, candidates, ped,
                                  minAge) {
  drawHaremGroups(
    makeHaremSetUp(numGp, currentGroups, candidates, ped, minAge), numGp
  )
}
