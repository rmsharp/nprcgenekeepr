## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Add animals to a breeding group or form new groups
#'
#' Part of Group Formation
#'
#' \code{groupAddAssign} finds the largest group that can be formed by adding
#' unrelated animals from a set of candidate IDs to an existing group, to a new
#' group it has formed from a set of candidate IDs or if more than 1 group
#' is desired, it finds the set of groups with the largest average size.
#'
#' The function implements a maximal independent set (MIS) algorithm to find
#' groups of unrelated animals. A set of animals may have many different MISs of
#' varying sizes, and finding the largest would require traversing all possible
#' combinations of animals. Since this could be very time consuming, this
#' algorithm produces a random sample of the possible MISs, and selects from
#' these. The size of the random sample is determined by the specified number
#' of iterations.
#'
#' @param candidates Character vector of IDs of the animals available for
#' use in forming the groups. The animals that may be present in
#' \code{currentGroups} are not included within \code{candidates}.
#' @param currentGroups List of character vectors of IDs of animals currently
#' assigned to groups.
#' Defaults to a list with character(0) in each sublist element (one for each
#' group being formed) assuming no groups are prepopulated.
#' @inheritParams meanKinship
#' @inheritParams getPotentialSires
#' @param threshold Numeric value indicating the minimum kinship level to be
#' considered in group formation. Pairwise kinship below this level will be
#' ignored. The default value is 0.015625.
#' @param ignore List of character vectors representing the sex combinations
#' to be ignored. If provided, the vectors in the list specify if pairwise
#' kinship should be ignored between certain sexes.
#' Default is to ignore all pairwise kinship between females.
#' @param minAge Integer value indicating the minimum age to consider in group
#' formation. Pairwise kinships involving an animal of this age or younger will
#'  be ignored. Default is 1 year.
#' @param iter Integer indicating the number of times to perform the random
#' group formation process. Default value is 1000 iterations.
#' @param numGp Integer value indicating the number of groups that should be
#' formed from the list of IDs. Default is 1.
#' @param harem Logical variable when set to \code{TRUE}, the formed groups
#' have a single male at least \code{minAge} old.
#' @param sexRatio Numeric value indicating the ratio of females to males x
#' from 0.5 to 20 by increments of 0.5.
#' @param withKin Logical variable when set to \code{TRUE}, the kinship
#' matrix for the group is returned along with the group and score.
#' Defaults to not return the kinship matrix. This maintains compatibility with
#' earlier versions.
#' @param maxCandidates Integer value indicating the maximum number of
#' distinct candidate solutions to retain during the simulation (issue #146
#' Slice 1). Default is 5.
#' @param exhaustive Logical. When \code{TRUE}, enumerate every maximal
#' independent set of the conflict graph instead of random sampling (issue
#' #146 Slice 2), subject to \code{maxExhaustiveCandidates}/
#' \code{exhaustiveTimeLimit}. Only supported for \code{numGp = 1},
#' \code{harem = FALSE}, \code{sexRatio = 0} -- any other combination
#' \code{stop()}s with a message naming the specific unsupported condition,
#' rather than silently falling back to sampling. Default is \code{FALSE}
#' (the existing sampling behavior, unchanged).
#' @param maxExhaustiveCandidates Integer. Pre-flight feasibility ceiling
#' for \code{exhaustive = TRUE}: a candidate pool larger than this
#' \code{stop()}s before any enumeration runs. Default is 20.
#' @param exhaustiveTimeLimit Numeric. Wall-clock seconds allowed for
#' \code{exhaustive = TRUE}'s search before it truncates gracefully
#' (\code{exhaustive = FALSE} in the return value, not an error). Default
#' is 10.
#' @param updateProgress Function or NULL. If this function is defined, it
#' will be called during each iteration to update a
#' \code{shiny::Progress} object.
#'
#' @return A list with list items \code{group}, \code{score}, \code{candidates}
#' and optionally \code{groupKin}.
#' The list item \code{group} contains a list of the best group(s) produced
#' during the simulation (an alias for \code{candidates[[1]]$group}, kept for
#' backward compatibility).
#' The list item \code{score} provides the score associated with the group(s)
#' (an alias for \code{candidates[[1]]$score}).
#' The list item \code{candidates} is a list of up to \code{maxCandidates}
#' distinct candidate solutions (default 5; issue #125, configurable per
#' issue #146 Slice 1), each a list with its own \code{group}, \code{score}
#' and, when \code{withKin = TRUE}, \code{groupKin}, ordered best-scoring
#' first. Candidates are deduplicated by partition content, not by score --
#' two trials with the same score but different membership both count as
#' distinct candidates; two trials with identical membership count once.
#' The list item \code{groupKin} contains the subset of the kinship matrix
#' that is specific for each group formed in the best candidate (an alias for
#' \code{candidates[[1]]$groupKin}).
#' When \code{exhaustive = TRUE} was requested (issue #146 Slice 2), three
#' additional top-level items are present -- absent entirely, not merely
#' \code{NULL}, when \code{exhaustive = FALSE} (the default): \code{exhaustive}
#' (logical, whether the search completed before its wall-clock deadline),
#' \code{examined} (integer, the total number of distinct maximal
#' independent sets found), and \code{retentionRule} (character, describing
#' the top-\code{maxCandidates} cutoff actually applied to \code{candidates}).
#'
#' @references Vinson, A. and Raboin, M.J. (2015) "A Practical Approach for
#' Designing Breeding Groups to Maximize Genetic Diversity in a Large Colony
#' of Captive Rhesus Macaques (\emph{Macaca mulatta})" \emph{Journal of the
#' American Association for Laboratory Animal Science}, 2015 Nov, Vol.54(6),
#' pp.700-707.
#' @export
#' @examples
#' library(nprcgenekeepr)
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' breederPed <- qcStudbook(examplePedigree,
#'   minParentAge = 2,
#'   reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#' focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
#'   is.na(breederPed$dam)) &
#'   is.na(breederPed$exit)]
#' ped <- setPopulation(ped = breederPed, ids = focalAnimals)
#' trimmedPed <- trimPedigree(focalAnimals, breederPed)
#' probands <- ped$id[ped$population]
#' ped <- trimPedigree(probands, ped,
#'   removeUninformative = FALSE,
#'   addBackParents = FALSE
#' )
#' geneticValue <- reportGV(ped,
#'   guIter = 50, # should be >= 1000
#'   guThresh = 3,
#'   byID = TRUE,
#'   updateProgress = NULL
#' )
#' trimmedGeneticValue <- reportGV(trimmedPed,
#'   guIter = 50, # should be >= 1000
#'   guThresh = 3,
#'   byID = TRUE,
#'   updateProgress = NULL
#' )
#' candidates <- trimmedPed$id[trimmedPed$birth < as.Date("2013-01-01") &
#'   !is.na(trimmedPed$birth) &
#'   is.na(trimmedPed$exit)]
#' haremGrp <- groupAddAssign(
#'   kmat = trimmedGeneticValue[["kinship"]],
#'   ped = trimmedPed,
#'   candidates = candidates,
#'   iter = 10, # should be >= 1000
#'   numGp = 6,
#'   harem = TRUE
#' )
#' haremGrp$group
#' sexRatioGrp <- groupAddAssign(
#'   kmat = trimmedGeneticValue[["kinship"]],
#'   ped = trimmedPed,
#'   candidates = candidates,
#'   iter = 10L, # should be >= 1000L
#'   numGp = 6L,
#'   sexRatio = 9.0
#' )
#' sexRatioGrp$group
groupAddAssign <- function(candidates,
                           kmat,
                           ped,
                           currentGroups = list(character(0L)),
                           threshold = 0.015625, ignore = list(c("F", "F")),
                           minAge = 1.0, iter = 1000L,
                           numGp = 1L, harem = FALSE,
                           sexRatio = 0.0, withKin = FALSE,
                           maxCandidates = 5L,
                           exhaustive = FALSE,
                           maxExhaustiveCandidates = 20L,
                           exhaustiveTimeLimit = 10.0,
                           updateProgress = NULL) {
  if (length(currentGroups) > numGp) {
    stop(
      "Cannot have more groups with seed animals than number of ",
      "groups to be formed."
    )
  }
  kmat <- filterKinMatrix(union(candidates, unlist(currentGroups)), kmat)
  kin <- getAnimalsWithHighKinship(
    kmat, ped, threshold, currentGroups, ignore,
    minAge
  )

  # Filtering out candidates related to current group members
  conflicts <- unique(c(
    unlist(kin[unlist(currentGroups)]),
    unlist(currentGroups)
  ))
  candidates <- setdiff(candidates, conflicts)


  kin <- addAnimalsWithNoRelative(kin, candidates)

  # Exhaustive mode (issue #146 Slice 2) is a parallel search strategy that
  # bypasses the random-sampling loop below entirely -- scope (D2) and
  # feasibility (D5) are checked, then enumeration replaces sampling.
  if (exhaustive) {
    return(.groupAddAssignExhaustive(
      candidates, kin, currentGroups, ped, minAge, numGp, harem, sexRatio,
      withKin, kmat, maxCandidates, maxExhaustiveCandidates,
      exhaustiveTimeLimit
    ))
  }

  if (harem &&
      length(getPotentialSires(candidates, ped, minAge)) < numGp) {
    stop(
      "User selected to form ",
      numGp,
      " harems with only ",
      length(getPotentialSires(candidates, ped, minAge)),
      " males at least ",
      minAge,
      " years old in the list of candidates."
    )
  }

  # Starting the group assignment simulation. Up to maxCandidates distinct
  # candidate solutions are retained (default 5; issue #125, configurable per
  # issue #146 Slice 1), deduplicated by canonicalized partition content --
  # not merely by score, since two trials with the same score but different
  # membership both count (see canonicalizePartition() below, Dragon R4).
  # Each new trial is compared only against the current up-to-maxCandidates
  # retained candidates, not the full trial history so far
  # (O(iter x maxCandidates), not O(iter^2)): safe because a partition's
  # score is a pure function of its own membership, so a partition once
  # evicted for scoring no better than the retained set can never later
  # re-qualify at that same score.
  retained <- list()

  for (k in 1L:iter) {
    groupMembers <- fillGroupMembers(
      candidates, currentGroups, kin, ped, harem,
      minAge, numGp, sexRatio
    )

    # Score the resulting groups
    score <- min(lengths(groupMembers))
    signature <- canonicalizePartition(groupMembers)

    alreadyRetained <- any(vapply(
      retained, function(r) identical(r$signature, signature), logical(1L)
    ))

    if (!alreadyRetained) {
      if (length(retained) < maxCandidates) {
        retained[[length(retained) + 1L]] <- list(
          groupMembers = groupMembers, score = score, signature = signature
        )
      } else {
        retainedScores <- vapply(retained, function(r) r$score, numeric(1L))
        worstIdx <- which.min(retainedScores)
        if (score > retainedScores[worstIdx]) {
          retained[[worstIdx]] <- list(
            groupMembers = groupMembers, score = score, signature = signature
          )
        }
      }
    }

    # Updating the progress bar, if applicable
    if (!is.null(updateProgress)) {
      updateProgress()
    }
  }

  # Best candidate first; ties broken by discovery order (order() is not
  # guaranteed stable for all methods, so break ties explicitly rather than
  # relying on it).
  retainedScores <- vapply(retained, function(r) r$score, numeric(1L))
  retained <- retained[order(-retainedScores, seq_along(retained))]

  retained <- lapply(retained, function(r) {
    r$groupMembers <- addGroupOfUnusedAnimals(
      r$groupMembers, candidates, ped, minAge, harem
    )
    r
  })

  groupMembersReturn(retained, withKin, kmat)
}

#' Canonicalize a group partition for equality comparison
#'
#' Sorts IDs within each group, then sorts groups by their own signature, so
#' two partitions that differ only in group order or within-group ID order
#' compare as identical. Used to deduplicate candidate solutions by partition
#' content rather than by score (issue #125, Dragon R4).
#'
#' @param groupMembers List of character vectors, one per group.
#' @return A single character string signature.
#' @noRd
canonicalizePartition <- function(groupMembers) {
  groupSignatures <- vapply(
    groupMembers,
    function(g) paste(sort(g), collapse = ","),
    character(1L)
  )
  paste(sort(groupSignatures), collapse = ";")
}

#' Exhaustive-mode branch of groupAddAssign (issue #146 Slice 2)
#'
#' Enumerates every maximal independent set of the (already conflict-
#' filtered) candidate pool via \code{\link{.enumerateMaximalIndependentSets}},
#' subject to D2's scope restriction and D5's two-layer feasibility guard,
#' then routes the results through the SAME \code{addGroupOfUnusedAnimals()}/
#' \code{groupMembersReturn()} pipeline the sampling path uses (plan Sec
#' 2.5/2.6) so the return shape is identical between the two modes apart from
#' the three new top-level fields (D7).
#'
#' @param candidates Character vector, already conflict-filtered against
#' \code{currentGroups} by the caller.
#' @param kin The conflict adjacency list, already including an \code{NA}
#' entry for every candidate with no conflicts.
#' @inheritParams groupAddAssign
#' @return See \code{\link{groupMembersReturn}}.
#' @noRd
.groupAddAssignExhaustive <- function(candidates, kin, currentGroups, ped,
                                      minAge, numGp, harem, sexRatio,
                                      withKin, kmat, maxCandidates,
                                      maxExhaustiveCandidates,
                                      exhaustiveTimeLimit) {
  # D2/D9: eligibility scope, checked before D5's ceiling and before any
  # enumeration runs. Each stop() names the specific violated condition
  # rather than silently falling back to sampling (Dragon-precedent: matches
  # the existing harem-infeasibility stop() below in groupAddAssign()).
  if (numGp != 1L) {
    stop(
      "Exhaustive mode is only supported for numGp = 1 (got numGp = ",
      numGp, ")."
    )
  }
  if (harem) {
    stop("Exhaustive mode does not support harem group formation.")
  }
  if (sexRatio != 0.0) {
    stop(
      "Exhaustive mode does not support a non-zero sexRatio (got sexRatio = ",
      sexRatio, ")."
    )
  }
  if (length(candidates) > maxExhaustiveCandidates) {
    stop(
      "Exhaustive mode candidate pool (", length(candidates),
      ") exceeds maxExhaustiveCandidates (", maxExhaustiveCandidates, ")."
    )
  }

  enumResult <- .enumerateMaximalIndependentSets(
    candidates = candidates, kin = kin, cap = maxExhaustiveCandidates,
    deadline = Sys.time() + exhaustiveTimeLimit
  )

  # The seed simply unions onto every enumerated set (plan Sec 2.4): every
  # candidate is already guaranteed compatible with the seed by the earlier
  # conflict-filtering step in groupAddAssign(), and seed IDs are never part
  # of `candidates`, so no dedup is needed.
  seed <- if (length(currentGroups) >= 1L) {
    currentGroups[[1L]]
  } else {
    character(0L)
  }

  retained <- lapply(enumResult$sets, function(set) {
    groupMembers <- list(c(seed, set))
    list(
      groupMembers = groupMembers,
      score = min(lengths(groupMembers)),
      signature = canonicalizePartition(groupMembers)
    )
  })

  # A deadline elapsed before even the first maximal independent set was
  # found leaves `retained` empty -- fall back to a single seed-only
  # candidate so the pipeline below never receives zero candidates (which
  # groupMembersReturn() cannot represent). This still correctly reports
  # exhaustive = FALSE via `enumResult$truncated` below.
  if (length(retained) == 0L) {
    groupMembers <- list(seed)
    retained <- list(list(
      groupMembers = groupMembers,
      score = length(seed),
      signature = canonicalizePartition(groupMembers)
    ))
  }

  retainedScores <- vapply(retained, function(r) r$score, numeric(1L))
  retained <- retained[order(-retainedScores, seq_along(retained))]
  retained <- utils::head(retained, maxCandidates)

  retained <- lapply(retained, function(r) {
    r$groupMembers <- addGroupOfUnusedAnimals(
      r$groupMembers, candidates, ped, minAge, harem
    )
    r
  })

  groupMembersReturn(
    retained, withKin, kmat,
    exhaustive = !enumResult$truncated,
    examined = enumResult$examined,
    retentionRule = paste0(
      "top-", maxCandidates, " by score (min group size), N = ",
      length(retained)
    )
  )
}
