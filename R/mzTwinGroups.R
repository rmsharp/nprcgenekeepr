## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Group chained MZ twin declarations
#'
#' Union-find over the declared MZ twin pairs, as kinship2's own mzgrp: A-B
#' and B-C make A, B and C one group. \code{kinship()} corrects each group's
#' kinship (R/kinship.R), and \code{twinRelationsForSet()} declares the
#' members of each group that a trimmed pedigree holds (R/kinshipForAnimals.R).
#'
#' @param first,second integer vectors of one length: the positions, from 1 to
#'   \code{n}, of the two animals of each declared pair.
#' @param n the number of positions.
#' @return An integer vector of length \code{n}: each position's group, named
#'   by the smallest position in it.
#' @noRd
mzTwinGroups <- function(first, second, n) {
  group <- seq_len(n)
  repeat {
    if (all(group[first] == group[second])) {
      break
    }
    for (i in seq_along(first)) {
      group[first[i]] <- group[second[i]] <- min(group[c(first[i], second[i])])
    }
  }
  group
}

## The error for an MZ declaration naming an animal the ids do not hold:
## kinship() and twinRelationsForSet() raise it (kinshipGeneral() keeps its
## own copy of the text, word for word).
# nolint start: nonportable_path_linter.
mzTwinIdsAbsentMessage <-
  "All twinRelations id1/id2 values must be present in id."
# nolint end: nonportable_path_linter.
