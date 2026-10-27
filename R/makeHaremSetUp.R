## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Work out once what every harem trial starts from
#'
#' Everything a harem trial needs before it draws its sires is the same in
#' every trial: which groups still need a sire, the potential sires among the
#' candidates and the candidates who are not potential sires. Finding them
#' reads every animal's age (\code{getPotentialSires()}), so
#' \code{groupAddAssign()} builds this once per call and each trial draws its
#' sires from it with \code{drawHaremGroups()}.
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
#' @return A list: \code{needsSire}, one logical per group, \code{TRUE} when
#' its seed animals hold no potential sire; \code{availableSires}, the
#' potential sires among the candidates who are not seed animals;
#' \code{seeds}, each group's seed animals (\code{groupSeeds()}); and
#' \code{nonSires}, the candidates who are not potential sires.
#'
#' @noRd
makeHaremSetUp <- function(numGp, currentGroups, candidates, ped, minAge) {
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
  list(
    needsSire = needsSire,
    availableSires = availableSires,
    seeds = groupSeeds(numGp, currentGroups),
    nonSires = removePotentialSires(candidates, minAge, ped)
  )
}

#' Draw the sires of one harem trial
#'
#' @param haremSetUp the list \code{makeHaremSetUp()} returns.
#' @param numGp integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @return The trial's starting groupMembers list: each group's seed animals,
#' after a sire drawn at random from \code{haremSetUp$availableSires} for each
#' group that needs one.
#'
#' @noRd
drawHaremGroups <- function(haremSetUp, numGp) {
  needsSire <- haremSetUp$needsSire
  groupMembers <- list()
  sires <- character(0L)
  if (any(needsSire)) {
    sires <- sample(haremSetUp$availableSires, sum(needsSire), replace = FALSE)
  }
  seeds <- haremSetUp$seeds
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
