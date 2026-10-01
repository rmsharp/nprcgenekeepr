## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Form breeding groups to match a target sex ratio
#'
#' The sex ratio is the number of non-males (females and animals of other or
#' unknown sex) per male.
#'
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @param groupMembers list initialized and ready to receive groups with the
#' desired sex ratios that are created within this function
#' @param grpNum is a list \code{numGp} long with each member a single integer
#' group number, \code{1} through \code{numGp}, as made by
#' \code{\link{makeGroupNum}}.
#' @param kin list of animals and those animals who are related above a
#' threshold value.
#' @inheritParams getPotentialSires
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal younger than this age are
#' ignored; an animal exactly this old is not ignored. There is no default.
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. There is no default.
#' @param sexRatio numeric value indicating the number of non-males per male.
#' Values from 0.5 to 20 in steps of 0.5 are typical, but the range is not
#' enforced.
#' @return The \code{groupMembers} list, with one character vector of animal
#'         IDs per group (\code{numGp} groups), each filled so that its sex
#'         ratio is as close as possible to the ratio specified by
#'         \code{sexRatio}.
#' @export
#' @examples
#' library(nprcgenekeepr)
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' examplePedigree <- examplePedigree[1:300, ] # Comment out for full example
#' ped <- qcStudbook(examplePedigree,
#'   minParentAge = 2L, reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#'
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
#' currentGroups <- list(1)
#' currentGroups[[1]] <- examplePedigree$id[1L:3L]
#' candidates <- examplePedigree$id[examplePedigree$status == "ALIVE"]
#' threshold <- 0.015625
#' kin <- getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups,
#'   ignore = list(c("F", "F")), minAge = 1L
#' )
#' # Filtering out candidates related to current group members
#' conflicts <- unique(c(
#'   unlist(kin[unlist(currentGroups)]),
#'   unlist(currentGroups)
#' ))
#' candidates <- setdiff(candidates, conflicts)
#'
#' kin <- addAnimalsWithNoRelative(kin, candidates)
#'
#' ignore <- NULL
#' minAge <- 1.0
#' numGp <- 1L
#' harem <- FALSE
#' sexRatio <- 0.0
#' withKin <- FALSE
#' groupMembers <- nprcgenekeepr::makeGroupMembers(numGp,
#'   currentGroups,
#'   candidates,
#'   ped,
#'   harem = harem,
#'   minAge = minAge
#' )
#' groupMembersStart <- groupMembers
#' grpNum <- nprcgenekeepr::makeGroupNum(numGp)
#'
#' groupMembers <- fillGroupMembersWithSexRatio(
#'   candidates, groupMembers, grpNum, kin, ped, minAge, numGp,
#'   sexRatio = 1.0
#' )
fillGroupMembersWithSexRatio <-
  function(candidates, groupMembers, grpNum, kin, ped, minAge, numGp,
           sexRatio) {
    potentialSires <- getPotentialSires(candidates, ped, minAge)
    availableMales <- makeAvailable(potentialSires, numGp)
    availableFemales <- makeAvailable(setdiff(candidates, potentialSires),
                                      numGp)

    repeat {
      if (isEmpty(grpNum)) {
        break
      }

      # Select a group at random
      i <- sample(grpNum, 1L)[[1L]]

      # Select an animal that can be added to this group and add it
      ratio <- calculateSexRatio(groupMembers[[i]], ped)
      if (is.na(ratio)) {
        ratio <- 0.0
      } ## no seed animals

      if (ratio < sexRatio) { ## need female
        id <- sample(availableFemales[[i]], 1L)
        availableFemales <-
          removeSelectedAnimalFromAvailableAnimals(availableFemales, id, numGp)
      } else if (abs(sexRatio - calculateSexRatio(groupMembers[[i]], ped,
        additionalMales = 1L
      )) <
        abs(sexRatio - calculateSexRatio(groupMembers[[i]], ped,
          additionalFemales = 1L
        ))) { # may need male
        id <- sample(availableMales[[i]], 1L)
        availableMales <-
          removeSelectedAnimalFromAvailableAnimals(availableMales, id, numGp)
      } else {
        id <- sample(availableFemales[[i]], 1L)
        availableFemales <-
          removeSelectedAnimalFromAvailableAnimals(availableFemales, id,
                                                   numGp)
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
