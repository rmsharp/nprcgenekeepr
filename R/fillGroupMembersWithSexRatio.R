#' Forms breeding group(s) with an effort to match a specified sex ratio
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#' @description The sex ratio is the ratio of females to males.
#'
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @param groupMembers list initialized and ready to receive groups with the
#' desired sex ratios that are created within this function
#' @param grpNum is a list \code{numGp} long with each member an integer
#' vector of \code{1:numGp}.
#' @param kin list of animals and those animals who are related above a
#' threshold value.
#' @param ped dataframe that is the `Pedigree`. It contains pedigree
#' information including the IDs listed in \code{candidates}.
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @param sexRatio numeric value indicating the ratio of females to males x
#' from 0.5 to 20 by increments of 0.5.
fillGroupMembersWithSexRatio <-
  function(candidates, groupMembers, grpNum, kin, ped, minAge, numGp,
           sexRatio) {
  potentialSires <- getPotentialSires(candidates, minAge, ped)
  availableMales <- makeAvailable(potentialSires, numGp)
  availableFemales <- makeAvailable(setdiff(candidates, potentialSires), numGp)

  while (TRUE) {
    if (isEmpty(grpNum)) {
      break
    }

    # Select a group at random
    i <- sample(grpNum, 1)[[1]]

    # Select an animal that can be added to this group and add it
    ratio <- calculateSexRatio(groupMembers[[i]], ped)
    if (is.na(ratio))
      ratio <- 0 ## no seed animals

    if (ratio < sexRatio) { ## need female
      id <- sample(availableFemales[[i]], 1)
      availableFemales <-
        removeSelectedAnimalFromAvailableAnimals(availableFemales, id, numGp)
    } else { # may need male
      if (abs(sexRatio - calculateSexRatio(groupMembers[[i]], ped,
                                           additionalMales = 1)) <
          abs(sexRatio - calculateSexRatio(groupMembers[[i]], ped,
                                           additionalFemales = 1))) {
        id <- sample(availableMales[[i]], 1)
        availableMales <-
          removeSelectedAnimalFromAvailableAnimals(availableMales, id, numGp)
      } else {
        id <- sample(availableFemales[[i]], 1)
        availableFemales <-
          removeSelectedAnimalFromAvailableAnimals(availableFemales, id, numGp)
      }
    }
    groupMembers[[i]] <- c(groupMembers[[i]], id)
    # Remove all relatives from consideration for the group it was added to
    availableMales[[i]] <- setdiff(availableMales[[i]], kin[[id]])
    availableFemales[[i]] <- setdiff(availableFemales[[i]], kin[[id]])
    grpNum <- removeGroupIfNoAvailableAnimals(grpNum, availableMales)
    grpNum <- removeGroupIfNoAvailableAnimals(grpNum, availableFemales)
  }
  groupMembers
}
