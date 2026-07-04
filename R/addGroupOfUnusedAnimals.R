## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' addGroupOfUnusedAnimals adds a group to the saved groups if needed
#'

#' @param savedGroupMembers list of groups of animals in the form of a vector
#' of animal Ids.
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @inheritParams getPotentialSires
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
#' @param harem logical variable when set to \code{TRUE}, the formed groups
#' have a single male at least \code{minAge} old.
#'
#' @return A list of groups, which are each lists of animal Ids that are unused
#' animals at the end of the iteration.
#'
#' @noRd
addGroupOfUnusedAnimals <- function(savedGroupMembers, candidates, ped,
                                    minAge, harem) {
  if (harem) { # Sires were added to groupMembers
    candidates <- removePotentialSires(candidates, minAge, ped)
  }

  # Adding a group for the unused animals
  n <- length(savedGroupMembers) + 1L
  savedGroupMembers[[n]] <-
    ifelse(isEmpty(setdiff(candidates, unlist(savedGroupMembers))),
      NA, list(setdiff(candidates, unlist(savedGroupMembers)))
    )[[1L]]
  savedGroupMembers
}
