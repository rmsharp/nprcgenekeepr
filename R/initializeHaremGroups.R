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
#' @return Initial groupMembers list
#'
#' @noRd
initializeHaremGroups <- function(numGp, currentGroups, candidates, ped,
                                  minAge) {
  groupMembers <- list()
  if (length(currentGroups) > 0L) {
    for (i in seq_along(currentGroups)) {
      currentGroup <- currentGroups[[i]]
      if (length(getPotentialSires(currentGroup, ped, minAge)) > 1L) {
        stop(
          "User selected to form harems with more than one male, ",
          "There are ",
          length(getPotentialSires(currentGroup, ped, minAge)),
          " at least ", minAge, " years old in the current group ",
          i, "."
        )
      }
    }
  }
  needsSire <- groupsWithoutSire(numGp, currentGroups, ped, minAge)
  availableSires <- setdiff(
    getPotentialSires(candidates, ped, minAge), unlist(currentGroups)
  )
  if (length(availableSires) < sum(needsSire)) {
    stop(
      "User selected to form harems in ", numGp, " groups with ",
      "only ", length(availableSires),
      " males at least ",
      minAge, " years old in the list of candidates."
    )
  }

  sires <- character(0L)
  if (any(needsSire)) {
    sires <- sample(availableSires, sum(needsSire), replace = FALSE)
  }
  seeds <- groupSeeds(numGp, currentGroups)
  nextSire <- 0L
  for (i in seq_len(numGp)) {
    if (needsSire[i]) {
      nextSire <- nextSire + 1L
      groupMembers[[i]] <- c(sires[nextSire], seeds[[i]])
    } else {
      groupMembers[[i]] <- seeds[[i]]
    }
  }
  groupMembers
}
