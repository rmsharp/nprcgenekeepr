## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Form breeding groups to match a target sex ratio
#'
#' The sex ratio is the number of non-males (females and animals of other or
#' unknown sex) per male. A male is placed only if he is at least
#' \code{minAge} years old; a male younger than that, or with no birth date,
#' is left out of the groups.
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
#'   minSireAge = 2L, minDamAge = 2L, reportChanges = FALSE,
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
    # A male who is not a potential sire (under minAge, or with no birth date)
    # is placed nowhere: calculateSexRatio() counts every male as a male, so he
    # must not fill the female pool.
    males <- ped$id[ped$sex %in% sexCodes[["male"]]]
    femalePool <- setdiff(candidates, males)
    if (!sexRatioPoolsAdmitted(candidates, potentialSires, femalePool,
                               groupMembers, grpNum, kin, ped, numGp)) {
      return(fillGroupMembersWithSexRatioGeneral(
        candidates, groupMembers, grpNum, kin, ped, minAge, numGp, sexRatio
      ))
    }
    # Column i of each table marks the animals of that pool group i may still
    # take, so each draw samples exactly the vector the setdiff() bookkeeping
    # of fillGroupMembersWithSexRatioGeneral() gives.
    poolIds <- c(potentialSires, femalePool)
    availableMales <- matrix(TRUE, length(potentialSires), numGp)
    availableFemales <- matrix(TRUE, length(femalePool), numGp)
    malesRelated <- kinPositions(kin, poolIds, potentialSires)
    femalesRelated <- kinPositions(kin, poolIds, femalePool)

    # calculateSexRatio() counts the pedigree rows whose id is in the group,
    # males and the rest, and a row of unknown sex as both; these running
    # counts give it the same numbers without reading the pedigree each time.
    isMale <- ped$sex == sexCodes[["male"]]
    poolMale <- isMale[match(poolIds, ped$id)]
    inPed <- poolIds %in% ped$id
    addsMale <- as.integer(inPed & (is.na(poolMale) | poolMale))
    addsOther <- as.integer(inPed & (is.na(poolMale) | !poolMale))
    nMales <- vapply(groupMembers, function(ids) {
      length(ped$sex[ped$id %in% ids & isMale])
    }, integer(1L))
    nOthers <- vapply(groupMembers, function(ids) {
      length(ped$sex[ped$id %in% ids & !isMale])
    }, integer(1L))

    repeat {
      if (isEmpty(grpNum)) {
        break
      }

      # Select a group at random
      i <- sample(grpNum, 1L)[[1L]]

      # Select an animal that can be added to this group and add it
      size <- length(groupMembers[[i]])
      ratio <- sexRatioFromCounts(size, nMales[[i]], nOthers[[i]])
      if (is.na(ratio)) {
        ratio <- 0.0
      } ## no seed animals

      if (ratio < sexRatio) { ## need female
        id <- sample(femalePool[availableFemales[, i]], 1L)
        availableFemales[match(id, femalePool), ] <- FALSE
      } else if (abs(sexRatio - sexRatioFromCounts(size, nMales[[i]],
                                                   nOthers[[i]],
                                                   additionalMales = 1L)) <
        abs(sexRatio - sexRatioFromCounts(size, nMales[[i]], nOthers[[i]],
                                          additionalFemales = 1L))) {
        # may need male
        id <- sample(potentialSires[availableMales[, i]], 1L)
        availableMales[match(id, potentialSires), ] <- FALSE
      } else {
        id <- sample(femalePool[availableFemales[, i]], 1L)
        availableFemales[match(id, femalePool), ] <- FALSE
      }
      k <- match(id, poolIds)
      if (!(id %in% groupMembers[[i]])) {
        nMales[[i]] <- nMales[[i]] + addsMale[[k]]
        nOthers[[i]] <- nOthers[[i]] + addsOther[[k]]
      }
      groupMembers[[i]] <- c(groupMembers[[i]], id)
      # Remove all relatives from consideration for the group it was added to
      availableMales[malesRelated[[k]], i] <- FALSE
      availableFemales[femalesRelated[[k]], i] <- FALSE
      grpNum <- dropFinishedGroups(grpNum, availableMales, availableFemales)
    }
    groupMembers
  }

#' Whether the fast sex-ratio fill gives today's result
#'
#' \code{groupPoolsAdmitted()} for both pools, and pedigree ids as text with
#' none repeated, no potential sire of unknown sex (\code{getPotentialSires()}
#' gives \code{NA} for one), no group of a class (\code{c()} turns a factor's
#' or a Date's values into others, so the counts would not follow), and every
#' group number a single number that is one of the groups. Any other input runs
#' today's code.
#'
#' @inheritParams fillGroupMembersWithSexRatio
#' @param potentialSires the male pool.
#' @param femalePool the female pool.
#' @return \code{TRUE} or \code{FALSE}.
#' @noRd
sexRatioPoolsAdmitted <- function(candidates, potentialSires, femalePool,
                                  groupMembers, grpNum, kin, ped, numGp) {
  groupPoolsAdmitted(candidates, kin, c(potentialSires, femalePool), numGp) &&
    is.character(ped$id) && !anyDuplicated(ped$id) &&
    !anyNA(potentialSires) &&
    !any(vapply(groupMembers, is.object, logical(1L))) &&
    all(vapply(grpNum, function(g) is.numeric(g) && length(g) == 1L,
               logical(1L))) &&
    all(unlist(grpNum) %in% seq_len(numGp))
}

#' calculateSexRatio() from a group's size and counts
#'
#' The branches and arithmetic of \code{calculateSexRatio()} and
#' \code{getSexRatioWithAdditions()}, from the group's number of ids and its
#' counts of males and of other animals, so the same numbers.
#'
#' @param size the number of ids in the group.
#' @param males,others the group's counts as \code{calculateSexRatio()}
#' makes them.
#' @param additionalMales,additionalFemales as in
#' \code{calculateSexRatio()}.
#' @return The sex ratio, \code{Inf}, or \code{NA} for an empty group.
#' @noRd
sexRatioFromCounts <- function(size, males, others, additionalMales = 0L,
                               additionalFemales = 0L) {
  if (size == 0L) {
    if (additionalFemales > 0L && additionalMales == 0L) {
      return(Inf)
    }
    if (additionalFemales == 0L) {
      return(if (additionalMales == 0L) NA else 0.0)
    }
  } else if (males == 0L && additionalMales <= 0L) {
    return(Inf)
  }
  (others + additionalFemales) / (males + additionalMales)
}

#' Fill the groups to a sex ratio with today's code
#'
#' The body of \code{fillGroupMembersWithSexRatio()} before the performance
#' campaign's Phase 4, word for word, for the inputs
#' \code{sexRatioPoolsAdmitted()} does not admit.
#'
#' @inheritParams fillGroupMembersWithSexRatio
#' @return The \code{groupMembers} list, filled.
#' @noRd
fillGroupMembersWithSexRatioGeneral <-
  function(candidates, groupMembers, grpNum, kin, ped, minAge, numGp,
           sexRatio) {
    potentialSires <- getPotentialSires(candidates, ped, minAge)
    # A male who is not a potential sire (under minAge, or with no birth date)
    # is placed nowhere: calculateSexRatio() counts every male as a male, so he
    # must not fill the female pool.
    males <- ped$id[ped$sex %in% sexCodes[["male"]]]
    availableMales <- makeAvailable(potentialSires, numGp)
    availableFemales <- makeAvailable(setdiff(candidates, males), numGp)

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
