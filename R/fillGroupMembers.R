## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Form and fill a list of animal groups based on provided constraints
#'
#' @param candidates character vector of IDs of the animals available for
#' use in the group.
#' @param currentGroups list of character vectors of IDs of animals currently
#' assigned
#' to the group. Defaults to character(0) assuming no groups are existent.
#' @param kin list of animals and those animals who are related above a
#' threshold value.
#' @inheritParams getPotentialSires
#' @param harem logical variable when set to \code{TRUE}, the formed groups
#' have a single male at least \code{minAge} old.
#' @param minAge integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @param sexRatio numeric value indicating the ratio of females to males x
#' (from 0.5 to 20 by increments of 0.5 within the accompanying Shiny
#' application. A sex ratio of 0 ignores sex in making up groups.
#' @return A list of animal groups and their member animals
#'
#' @noRd
fillGroupMembers <- function(candidates,
                             currentGroups,
                             kin,
                             ped,
                             harem,
                             minAge,
                             numGp,
                             sexRatio) {
  groupMembers <- makeGroupMembers(
    numGp, currentGroups, candidates, ped,
    harem, minAge
  )
  grpNum <- makeGroupNum(numGp)

  if (harem) {
    # Sires were added to groupMembers
    candidates <- removePotentialSires(candidates, minAge, ped)
  }
  if (sexRatio != 0.0) {
    groupMembers <- fillGroupMembersWithSexRatio(
      candidates,
      groupMembers,
      grpNum,
      kin,
      ped,
      minAge,
      numGp,
      sexRatio
    )
    return(groupMembers)
  }
  if (!groupPoolsAdmitted(candidates, kin, candidates, numGp)) {
    return(fillGroupMembersGeneral(candidates, groupMembers, grpNum, kin,
                                   numGp))
  }
  # Column i of `available` marks the candidates (each once, in their order)
  # group i may still take, so each draw samples exactly the vector the
  # setdiff() bookkeeping of fillGroupMembersGeneral() gives, and the same
  # seed places the same animals.
  ids <- unique(unname(candidates))
  available <- matrix(TRUE, length(ids), numGp)

  # Whoever is already in a group (a harem's sampled sire, a supplied seed
  # animal) keeps his relatives out of that group's pool, as an animal the
  # loop places does below; a group left with no pool is finished. `[`, not
  # `[[`: a member with no relatives is absent from `kin` and gives nothing.
  for (i in seq_len(numGp)) {
    available[, i] <- ids %in% setdiff(ids, unlist(kin[groupMembers[[i]]]))
  }
  relatives <- kinPositions(kin, ids, ids)
  grpNum <- dropFinishedGroups(grpNum, available)

  repeat {
    if (isEmpty(grpNum)) {
      break
    }

    # Select a group at random
    i <- sample(grpNum, 1L)[[1L]]

    # Select an animal that can be added to this group and add it
    id <- sample(ids[available[, i]], 1L)
    groupMembers[[i]] <- c(groupMembers[[i]], id)
    k <- match(id, ids)
    available[k, ] <- FALSE

    # Remove all relatives from consideration for the group it was added to
    available[relatives[[k]], i] <- FALSE
    grpNum <- dropFinishedGroups(grpNum, available)
  }
  groupMembers
}

#' Whether the fast group fill gives today's result for these pools
#'
#' The fill from a true/false table matches the \code{setdiff()} bookkeeping
#' of \code{fillGroupMembersGeneral()} when the candidates are text with none
#' missing, there is at least one group, and the relatives of every animal of
#' the pools are text, a bare \code{NA} (\code{addAnimalsWithNoRelative()})
#' or nothing. Any other input runs today's code.
#'
#' @param candidates the candidates as given.
#' @param kin list of animals and their relatives.
#' @param poolIds the animals a group may draw.
#' @param numGp the number of groups.
#' @return \code{TRUE} or \code{FALSE}.
#' @noRd
groupPoolsAdmitted <- function(candidates, kin, poolIds, numGp) {
  is.character(candidates) && !anyNA(candidates) && isTRUE(numGp >= 1L) &&
    all(vapply(kin[unique(poolIds)], function(relatives) {
      is.null(relatives) || is.character(relatives) ||
        (is.logical(relatives) && all(is.na(relatives)))
    }, logical(1L)))
}

#' The positions in a pool of each animal's relatives
#'
#' @param kin list of animals and their relatives.
#' @param ids the animals whose relatives are wanted.
#' @param universe the pool the positions point into.
#' @return A list as long as \code{ids}: for each, the positions in
#' \code{universe} of the animals \code{kin[[id]]} names.
#' @noRd
kinPositions <- function(kin, ids, universe) {
  relatives <- kin[ids]
  positions <- match(unlist(relatives, use.names = FALSE), universe)
  owner <- rep.int(seq_along(ids), lengths(relatives))
  found <- !is.na(positions)
  split(positions[found], factor(owner[found], levels = seq_along(ids)))
}

#' Remove the group numbers of groups with an empty pool
#'
#' \code{removeGroupIfNoAvailableAnimals()} for pools held as columns of
#' true/false tables: a group is finished when any of its pools is empty, and
#' its number is removed with \code{setdiff()}, as there.
#'
#' @param grpNum the group numbers still being filled.
#' @param ... true/false tables, one column per group.
#' @return \code{grpNum} without the finished groups.
#' @noRd
dropFinishedGroups <- function(grpNum, ...) {
  left <- do.call(pmin, lapply(list(...), colSums))
  for (i in grpNum) {
    if (left[[i]] == 0L) {
      grpNum <- setdiff(grpNum, i)
    }
  }
  grpNum
}

#' Fill the groups with today's code
#'
#' The fill loop of \code{fillGroupMembers()} before the performance
#' campaign's Phase 4, word for word, for the inputs
#' \code{groupPoolsAdmitted()} does not admit.
#'
#' @inheritParams fillGroupMembers
#' @param groupMembers the groups as \code{makeGroupMembers()} made them.
#' @param grpNum the group numbers, as \code{makeGroupNum()} made them.
#' @return A list of animal groups and their member animals
#' @noRd
fillGroupMembersGeneral <- function(candidates, groupMembers, grpNum, kin,
                                    numGp) {
  available <- makeAvailable(candidates, numGp)

  # Whoever is already in a group (a harem's sampled sire, a supplied seed
  # animal) keeps his relatives out of that group's pool, as an animal the
  # loop places does below; a group left with no pool is finished. `[`, not
  # `[[`: a member with no relatives is absent from `kin` and gives nothing.
  for (i in seq_len(numGp)) {
    available[[i]] <- setdiff(available[[i]], unlist(kin[groupMembers[[i]]]))
  }
  grpNum <- removeGroupIfNoAvailableAnimals(grpNum, available)

  repeat {
    if (isEmpty(grpNum)) {
      break
    }

    # Select a group at random
    i <- sample(grpNum, 1L)[[1L]]

    # Select an animal that can be added to this group and add it
    id <- sample(available[[i]], 1L)
    groupMembers[[i]] <- c(groupMembers[[i]], id)
    available <-
      removeSelectedAnimalFromAvailableAnimals(available, id, numGp)

    # Remove all relatives from consideration for the group it was added to
    available[[i]] <- setdiff(available[[i]], kin[[id]])
    grpNum <- removeGroupIfNoAvailableAnimals(grpNum, available)
  }
  groupMembers
}
