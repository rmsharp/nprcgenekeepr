## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Collect the animals reachable from some animals, generation by generation
#'
#' The one place that says "keep collecting the parents (ancestors), the
#' offspring (descendants) or both of every animal found, until nothing new
#' turns up". \code{getProbandPedigree}, \code{getDescendantPedigree},
#' \code{getPedDirectRelatives} and \code{getLkDirectAncestors} each walk the
#' pedigree through it, so circular data ends the walk in all four.
#'
#' Each step takes the parents or offspring (through \code{getParents} and
#' \code{getOffspring}) of the animals first reached by the step before, and
#' keeps only those not found yet. A missing id (\code{NA}) is an id like any
#' other. An id with no row in \code{ped} is still found, but leads nowhere.
#'
#' @param ids character vector of the animals to start from.
#' @param ped data.frame with the columns \code{id}, \code{sire} and
#' \code{dam}.
#' @param direction \code{"ancestors"} walks up through the parents,
#' \code{"descendants"} down through the offspring, and \code{"both"} through
#' both, which reaches the whole connected family.
#' @return A list of character vectors, one per generation. The first is
#' \code{ids}, each once, in the order given. Each later one holds the ids first
#' reached at that step, in the order \code{getParents} and \code{getOffspring}
#' return them (for \code{"both"}, the parents first). No id appears twice.
#'
#' @noRd
walkPedigree <- function(ids, ped,
                         direction = c("ancestors", "descendants", "both")) {
  direction <- match.arg(direction)
  step <- switch(direction,
    ancestors = function(found) getParents(ped, found),
    descendants = function(found) getOffspring(ped, found),
    both = function(found) {
      union(getParents(ped, found), getOffspring(ped, found))
    }
  )
  newest <- unique(ids)
  seen <- newest
  generations <- list(newest)
  repeat {
    newest <- setdiff(step(newest), seen)
    if (length(newest) == 0L) {
      break
    }
    generations[[length(generations) + 1L]] <- newest
    seen <- c(seen, newest)
  }
  generations
}
