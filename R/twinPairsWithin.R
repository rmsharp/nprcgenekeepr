## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' The twin pairs whose two animals a pedigree holds
#'
#' The Pedigree Browser checks an uploaded twin/zygosity file against the
#' whole studbook, then hands each place that uses the pairs only the pairs
#' whose two animals it holds: the diagram builder and \code{kinship()} both
#' stop on an id they do not hold. So a pair with an animal outside a focal
#' trim is left out of that place, not an error.
#'
#' @param twins validated twin relations (\code{id1}, \code{id2},
#'   \code{code}), or \code{NULL}.
#' @param ped data frame with an \code{id} column.
#' @return the rows of \code{twins} whose \code{id1} and \code{id2} are both in
#'   \code{ped$id}; \code{NULL} when none are, or when \code{twins} is
#'   \code{NULL} (\code{ped} is not evaluated then, so a caller can pass a
#'   reactive that would halt with no pedigree loaded).
#' @noRd
.twinPairsWithin <- function(twins, ped) {
  if (is.null(twins)) {
    return(NULL)
  }
  keep <- twins$id1 %in% ped$id & twins$id2 %in% ped$id
  if (!any(keep)) {
    return(NULL)
  }
  twins[keep, , drop = FALSE]
}
