#' Make the initial groupMembers animal list
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return Initial groupMembers list
#'
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @param currentGroups list of character vectors of IDs of animals currently
#' assigned to the group. Defaults to character(0) assuming no groups are
#' existent.
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @param ped dataframe that is the `Pedigree`. It contains pedigree
#' information including the IDs listed in \code{candidates}.
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
initializeHaremGroups <- function(numGp, currentGroups, candidates, ped,
                                  minAge) {
  groupMembers <- list()
  if (length(currentGroups) > 0) {
    for (i in seq_len(length(currentGroups))) {
      currentGroup <- currentGroups[[i]]
      if (length(getPotentialSires(currentGroup, minAge, ped)) > 1)
        # makeFatalErrorTab(
        #   paste0("Fatal Error: User selected to form harems with more than ",
        #          "one male, There are ",
        #          length(getPotentialSires(currentGroup, minAge, ped)),
        #          " at least ", minAge, " years old in the current group ",
        #          i, "."))
      stop(paste0("User selected to form harems with more than one male, ",
                  "There are ",
                  length(getPotentialSires(currentGroup, minAge, ped)),
                  " at least ", minAge, " years old in the current group ",
                  i, "."))
    }
  }
  if (length(getPotentialSires(candidates, minAge, ped)) < numGp &
      length(getPotentialSires(unlist(currentGroups), minAge, ped)) == 0)
    # makeFatalErrorTab(
    #   paste0("Fatal Error: User selected to form harems with more than one ",
    #          "male. There are ",
    #          length(getPotentialSires(currentGroup, minAge, ped)),
    #          " at least ", minAge, " years old in the current group ",
    #          i, "."))
  stop(paste0("User selected to form harems in ", numGp, " groups with ",
              "only ", length(getPotentialSires(candidates, minAge, ped)),
              " males at least ",
              minAge, " years old in the list of candidates."))

  if (length(getPotentialSires(unlist(currentGroups), minAge, ped)) == 0) {
    ped <- ped[!is.na(ped$birth), ]
    sires <- sample(getPotentialSires(candidates, minAge, ped), numGp,
                    replace = FALSE)
    for (i in 1:numGp) {
      groupMembers[[i]] <- sires[i]
    }
  }
  if (length(currentGroups) > 0) {
    for (i in seq_len(length(currentGroups))) {
      currentGroup <- currentGroups[[i]]
      if (length(currentGroup) > 0) {
        if (length(getPotentialSires(currentGroup, minAge, ped)) > 0) {
          groupMembers[[i]] <- currentGroup
        } else {
          groupMembers[[i]] <- c(groupMembers[[i]], currentGroup)
        }
      }
    }
  }
  groupMembers
}
