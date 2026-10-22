## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Trim a pedigree to its analysis population and their ancestors
#'
#' Internal helper shared by the Genetic Value tab
#' (\code{\link{modGeneticValueServer}}) and
#' \code{\link{backfillColonySnapshots}}, so both prepare the pedigree for
#' \code{\link{reportGV}} the same way. The animals marked in the logical
#' \code{population} column are kept with their ancestors
#' (\code{removeUninformative = FALSE}, \code{addBackParents = FALSE}), and a
#' \code{gen} column is added when the pedigree has none.
#'
#' It does not decide what to do when no animal is marked: the tab falls back
#' to analyzing everyone, while \code{backfillColonySnapshots()} must not
#' (a date nobody was alive on has to stop, not analyze the whole colony), so
#' each caller makes that choice before calling.
#'
#' @param ped Pedigree data.frame with \code{id}, \code{sire}, \code{dam} and
#' a logical \code{population} column with at least one \code{TRUE}.
#' @return The trimmed pedigree, with a \code{gen} column.
#' @noRd
trimToAnalysisPopulation <- function(ped) {
  ped <- trimPedigree(ped$id[ped$population], ped,
    removeUninformative = FALSE, addBackParents = FALSE
  )
  if (!"gen" %in% names(ped)) {
    ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  }
  ped
}
