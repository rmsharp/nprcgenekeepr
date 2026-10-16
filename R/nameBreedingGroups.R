## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Put the names of the Breeding Groups boxes on the list of groups
#'
#' Breeding Groups names every box it shows (see \code{breedingGroupLabels()}),
#' and \code{getGeneticDiversityStats()} uses the names of the list it is given
#' as the heat map's row labels, but only when every group has a non-empty
#' name. So the names go on only when they fit: one text name per group, none
#' missing or empty. In every other case (no names, names for another number
#' of boxes, names that are not text, groups that are not a list of boxes) the
#' groups come back exactly as given and the heat map numbers its rows.
#'
#' @param groups List of character vectors of animal IDs, one per box, as
#' returned by \code{modBreedingGroupsServer}; anything else is returned as
#' given.
#' @param labels Character vector with one name per box, or \code{NULL}.
#' @return \code{groups}, named by \code{labels} when they fit, otherwise
#' unchanged.
#' @noRd
.nameBreedingGroups <- function(groups, labels) {
  fits <- is.list(groups) && length(groups) > 0L &&
    is.character(labels) && length(labels) == length(groups) &&
    !anyNA(labels) && all(nzchar(labels))
  if (fits) {
    names(groups) <- labels
  }
  groups
}
